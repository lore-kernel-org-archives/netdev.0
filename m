From: Ben Greear <greearb@candelatech.com>
Subject: Re: [iproute2] iproute2:  Fix 'addr flush secondary' logic.
Date: Thu, 12 Aug 2010 12:10:36 -0700
Message-ID: <4C64472C.9000302@candelatech.com>
References: <1281547182-1252-1-git-send-email-greearb@candelatech.com> <4C630B0A.9010304@hp.com> <4C6328A8.4070703@candelatech.com> <4C6444EA.1070704@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:46923 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754051Ab0HLTKj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Aug 2010 15:10:39 -0400
In-Reply-To: <4C6444EA.1070704@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/12/2010 12:00 PM, Brian Haley wrote:
> On 08/11/2010 06:48 PM, Ben Greear wrote:
>> Looks like the code was broken in several different places.
>>
>> * It ran only a single filter if there were multiple.
>> * Don't want to flush in a loop if you are doing primary
>>    because otherwise promoted seconaries will get deleted
>>    for each additional loop (10 in upstream code).
>> * No idea what a while (0); statement at the end of a for
>>    loop does, but I don't think it needed to be there!
>>
>> The attached patch makes it work for me, supporting
>> flushing primary or secondary addresses.
>
>> diff --git a/ip/ipaddress.c b/ip/ipaddress.c
>> index 5f0789c..803df17 100644
>> --- a/ip/ipaddress.c
>> +++ b/ip/ipaddress.c
>> @@ -637,7 +637,7 @@ int print_addrinfo_primary(const struct sockaddr_nl *who, struct nlmsghdr *n,
>>   {
>>   	struct ifaddrmsg *ifa = NLMSG_DATA(n);
>>
>> -	if (!ifa->ifa_flags&  IFA_F_SECONDARY)
>> +	if (ifa->ifa_flags&  IFA_F_SECONDARY)
>   		return 0;
>
> This should be:
>
> 	if (!(ifa->ifa_flags&  IFA_F_SECONDARY))
>
> as this function does the opposite of what it seems.

I see no reason to let it do the opposite of what it seems.

 From what I can tell, the original code never even called this
method anyway since it was the second filter and only the first
filter was used.


>> @@ -648,7 +648,7 @@ int print_addrinfo_secondary(const struct sockaddr_nl *who, struct nlmsghdr *n,
>>   {
>> 	struct ifaddrmsg *ifa = NLMSG_DATA(n);
>>
>> -	if (ifa->ifa_flags&  IFA_F_SECONDARY)
>> +	if (!(ifa->ifa_flags&  IFA_F_SECONDARY))
>   		return 0;
>
>> From testing, the original code here was correct.

It deleted addresses, but not how it was intended to work,
I think.

>> @@ -865,6 +865,13 @@ static int ipaddr_list_or_flush(int argc, char **argv, int flush)
>> 				printf("\n*** Round %d, deleting %d addresses ***\n", round, filter.flushed);
>> 				fflush(stdout);
>> 			}
>> +
>> +			/* If we are flushing, and specifying primary, then we want to flush only a single round.
>> +			 * Otherwise, we'll start flushing secondaries that were promoted to primaries
>> +			 */
>> +			if (!(filter.flags&  IFA_F_SECONDARY)&&  (filter.flagmask&  IFA_F_SECONDARY)) {
>> +				return 0;
>> +			}
>
> This doesn't seem to do anything, I see all my IPv4 addresses flushed if I
> run 'ip -4 -s a flush primary dev eth2'.  And it says it only deleted one
> when it deleted two addresses :-/  Also, if it did work, it should really goto
> a few lines above so it prints the summary stats:
>
>                          if (filter.flushed == 0) {
> flush_done:
>                                  if (show_stats) {
>
> Even when I corrected the lines above, it didn't work:
>
> # ip -4 a s dev eth2
> 2: eth2:<BROADCAST,MULTICAST,UP,LOWER_UP>  mtu 1500 qdisc mq state UP qlen 1000
>      inet 192.168.6.4/24 brd 192.168.6.255 scope global eth2
>
> # ip a a 192.168.6.100/24 brd + dev eth2
> # ip -4 a s dev eth2
> 2: eth2:<BROADCAST,MULTICAST,UP,LOWER_UP>  mtu 1500 qdisc mq state UP qlen 1000
>      inet 192.168.6.4/24 brd 192.168.6.255 scope global eth2
>      inet 192.168.6.100/24 brd 192.168.6.255 scope global secondary eth2
>
> # ./ip -4 -s -s -o a flush primary dev eth2
> 2: eth2    inet 192.168.6.4/24 brd 192.168.6.255 scope global eth2
>
> *** Round 1, deleting 1 addresses ***
> [missing *** Flush is complete after 1 round ***]
>
> # ip -4 a s dev eth2
> [nothing]
>
> Where did my .100 secondary address go?  Now this will bug me until I figure
> out why.  Maybe it's because I'm booted to 2.6.32.

Do you have the 'promote secondaries' sysctl enabled?  I think you
need that to have the secondaries not just dissappear upon removal
of the primary.

>> diff --git a/lib/libnetlink.c b/lib/libnetlink.c
>> index cfeb894..d18e8a0 100644
>
> Can you give an example of how you tested this double filter change?  My
> distro /sbin/ip seemed to work just fine.
>
>> -		if (status) {
>> +		if (msglen) {
>> 			fprintf(stderr, "!!!Remnant of size %d\n", status);
>> 			exit(1);
>> 		}
>
> Should the arg to the fprintf() be msglen too?

Yes, that should be fixed.

Thanks for the review..I'll make this change and show you the commands
I used for testing.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

