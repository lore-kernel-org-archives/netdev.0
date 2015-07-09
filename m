From: Miha Marolt <miham@beyondsemi.com>
Subject: Re: [BUG] "$ ss -a" incorrectly displays raw sockets as udp sockets
Date: Thu, 09 Jul 2015 17:09:27 +0200
Message-ID: <559E8EA7.2060600@beyondsemi.com>
References: <559E8178.9080808@beyondsemi.com> <559E8A1E.1060002@cumulusnetworks.com> <20150709145517.GA12466@angus-think.lan> <559E8BE2.20404@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bsemi.com ([84.255.202.183]:42423 "EHLO mail.beyondsemi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751216AbbGIPJa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jul 2015 11:09:30 -0400
In-Reply-To: <559E8BE2.20404@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 07/09/2015 04:57 PM, Nikolay Aleksandrov wrote:
> On 07/09/2015 04:55 PM, Vadim Kochan wrote:
>> On Thu, Jul 09, 2015 at 04:50:06PM +0200, Nikolay Aleksandrov wrote:
>>> On 07/09/2015 04:13 PM, Miha Marolt wrote:
>>>> Hi!
>>>>
>>>> I hope this is the right place to reports bugs. I apologize if it isn't.
>>>>
>>>> I have written a C program (see below for source code) that opens a raw socket on CentOS 7.1 Linux and binds it to some address (it doesn't use the port that I supplied, but that is not the point here). The "netstat" program correctly recognizes the socket as "raw", while "ss" program says it is "udp". Here are the relevant lines from the ss and netstat commands:
>>>>
>>>> $ netstat -an
>>>> raw        0      0 127.0.0.1:6             0.0.0.0:* 7
>>>>
>>>> $ ./ss -an
>>>> udp    UNCONN     21569  0      127.0.0.1:6 *:*
>>>>
>>>> Here is the version information
>>>>
>>>> $ netstat --version  # From CentOS 7.1.
>>>> net-tools 2.10-alpha
>>>>
>>>> $ ./ss --version  # Built from git.
>>>> ss utility, iproute2-ss150626
>>>>
>>>>
>>>> C source follows. If you store it in "main.c", then compile it with "$ gcc main.c -o main" and then run it by executing "$ sudo ./main".
>>>>
>>>> #include <arpa/inet.h>
>>>> #include <assert.h>
>>>> #include <sys/socket.h>
>>>> #include <stdio.h>
>>>> #include <unistd.h>
>>>>
>>>>
>>>> int main(void)
>>>> {
>>>>      // Create a raw socket.
>>>>      int sock = socket(AF_INET, SOCK_RAW, IPPROTO_TCP);
>>>>      if (sock == -1) { perror(NULL); goto exc_cleanup; }
>>>>
>>>>      // Bind socket to an address.
>>>>      struct sockaddr_in addr;
>>>>      addr.sin_family = AF_INET;
>>>>      inet_pton(AF_INET, "127.0.0.1", &addr.sin_addr);
>>>>      addr.sin_port = htons(27183);
>>>>
>>>>      int rc = bind(sock, (struct sockaddr*)&addr, sizeof(addr));
>>>>      if (rc != 0) { perror(NULL); goto exc_cleanup; }
>>>>
>>>>      // Wait until user presses <ENTER>.
>>>>      printf("\nPress <ENTER> to quit the program.\n");
>>>>      getchar();
>>>>
>>>> exc_cleanup:
>>>>      assert(!close(sock));
>>>> }
>>>>
>>>>
>>>> Best regards,
>>>> Miha
>>>
>>> Hi,
>>> I think this was changed by commit:
>>> 8250bc9ff4e5 ("ss: Unify inet sockets output")
>>> Because dgram_show_line() is used for both UDP and RAW sockets
>>> IPPROTO_UDP is used for both now and proto_name() returns "udp".
>>> CCed the patch author and attached a possible solution.
>>>
>>> Cheers,
>>>   Nik
>>> diff --git a/misc/ss.c b/misc/ss.c
>>> index 870cad185341..4de77e92c319 100644
>>> --- a/misc/ss.c
>>> +++ b/misc/ss.c
>>> @@ -1554,6 +1554,8 @@ out:
>>>   static char *proto_name(int protocol)
>>>   {
>>>   	switch (protocol) {
>>> +	case IPPROTO_RAW:
>>> +		return "raw";
>>>   	case IPPROTO_UDP:
>>>   		return "udp";
>>>   	case IPPROTO_TCP:
>>> @@ -2398,7 +2400,7 @@ static int dgram_show_line(char *line, const struct filter *f, int family)
>>>   	if (n < 9)
>>>   		opt[0] = 0;
>>>   
>>> -	inet_stats_print(&s, IPPROTO_UDP);
>>> +	inet_stats_print(&s, dg_proto == UDP_PROTO ? IPPROTO_UDP : IPPROTO_RAW);
>>>   
>>>   	if (show_details && opt[0])
>>>   		printf(" opt:\"%s\"", opt);
>> Yeah, it fixed the issue, just tested the fix.
>>
> Great, I'll submit it in a minute.
> Thanks for testing!

Thank you very much for the fast fix!

I've found another bug: command "$ ss" doesn't display only tcp sockets 
as the man page ss(8) says (file man/man8/ss.8 in iproute2 git repo). It 
also displays e.g. unix sockets. The man page says "When no option is 
used ss displays a list of open non-listening TCP sockets that have 
established connection.".


Regards,
Miha
