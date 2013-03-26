From: Benoit Lourdelet <blourdel@juniper.net>
Subject: Re: [RFC][PATCH] iproute: Faster ip link add, set and delete
Date: Tue, 26 Mar 2013 11:51:07 +0000
Message-ID: <CD773D0D.7614%blourdel@juniper.net>
References: <CAOaVG17Cjj3epC2LRkDVdoqNWno=XjH4nhfiNVeceS=0d=Nyrw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Serge Hallyn <serge.hallyn@ubuntu.com>
To: Stephen Hemminger <stephen@networkplumber.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og101.obsmtp.com ([64.18.2.155]:58764 "EHLO
	exprod7og101.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757801Ab3CZMCL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 08:02:11 -0400
Received: from mail12-tx2 (localhost [127.0.0.1])	by mail12-tx2-R.bigfish.com
 (Postfix) with ESMTP id 92E41A0343	for
 <netdev@vger.kernel.org.FOPE.CONNECTOR.OVERRIDE>; Tue, 26 Mar 2013 11:51:10
 +0000 (UTC)
In-Reply-To: <CAOaVG17Cjj3epC2LRkDVdoqNWno=XjH4nhfiNVeceS=0d=Nyrw@mail.gmail.com>
Content-Language: en-US
Content-ID: <E8524E03B60C124ABCA7A71C9051C987@namprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I re-tested with the patch and got the following results on a 32x 2Ghz
core system.

# veth 	add 	delete
1000 	36 	34
3000 	259 	137
4000 	462 	195
5000 	729     N/A

The script to create is the following :
for i in `seq 1 5000`; do
	sudo ip link add type veth
Done


The script to delete:
for d in /sys/class/net/veth*; do
	ip link del `basename $d` 2>/dev/null || true
Done

There is a very good improvement in deletion.



iproute2 does not seems to be well multithread as I get time divided by=
 a
factor of 2 with a 8x  3.2 Ghz core system.

I don=B9t know if that is the improvement you expected ?

Would the iproute2 redesign you mentioned help improve performance even
further ?


As a reference : Iproute2 baseline w/o patch:

# veth 	add 	delete

1000 	57 	70
2000 	193 	250
3000 	435 	510
4000 	752 	824
5000 	1123 	1185

Regards

Benoit




On 22/03/2013 23:27, "Stephen Hemminger" <stephen@networkplumber.org>
wrote:

>The whole ifindex map is a design mistake at this point.
>Better off to do a lazy cache or something like that.
>
>
>On Fri, Mar 22, 2013 at 3:23 PM, Eric W. Biederman
><ebiederm@xmission.com> wrote:
>>
>> Because ip link add, set, and delete map the interface name to the
>> interface index by dumping all of the interfaces before performing
>> their respective commands.  Operations that should be constant time
>> slow down when lots of network interfaces are in use.  Resulting
>> in O(N^2) time to work with O(N) devices.
>>
>> Make the work that iproute does constant time by passing the interfa=
ce
>> name to the kernel instead.
>>
>> In small scale testing on my system this shows dramatic performance
>> increases of ip link add from 120s to just 11s to add 5000 network
>> devices.  And from longer than I cared to wait to just 58s to delete
>> all of those interfaces again.
>>
>> Cc: Serge Hallyn <serge.hallyn@ubuntu.com>
>> Reported-by: Benoit Lourdelet <blourdel@juniper.net>
>> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
>> ---
>>
>> I think I am bungling the case where people specify an ifindex as if=
NNNN
>> but does anyone care?
>>
>>  ip/iplink.c |   19 +------------------
>>  1 files changed, 1 insertions(+), 18 deletions(-)
>>
>> diff --git a/ip/iplink.c b/ip/iplink.c
>> index ad33611..6dffbf0 100644
>> --- a/ip/iplink.c
>> +++ b/ip/iplink.c
>> @@ -533,8 +533,6 @@ static int iplink_modify(int cmd, unsigned int
>>flags, int argc, char **argv)
>>                 }
>>         }
>>
>> -       ll_init_map(&rth);
>> -
>>         if (!(flags & NLM_F_CREATE)) {
>>                 if (!dev) {
>>                         fprintf(stderr, "Not enough information:
>>\"dev\" "
>> @@ -542,27 +540,12 @@ static int iplink_modify(int cmd, unsigned int
>>flags, int argc, char **argv)
>>                         exit(-1);
>>                 }
>>
>> -               req.i.ifi_index =3D ll_name_to_index(dev);
>> -               if (req.i.ifi_index =3D=3D 0) {
>> -                       fprintf(stderr, "Cannot find device \"%s\"\n=
",
>>dev);
>> -                       return -1;
>> -               }
>> +               name =3D dev;
>>         } else {
>>                 /* Allow "ip link add dev" and "ip link add name" */
>>                 if (!name)
>>                         name =3D dev;
>>
>> -               if (link) {
>> -                       int ifindex;
>> -
>> -                       ifindex =3D ll_name_to_index(link);
>> -                       if (ifindex =3D=3D 0) {
>> -                               fprintf(stderr, "Cannot find device
>>\"%s\"\n",
>> -                                       link);
>> -                               return -1;
>> -                       }
>> -                       addattr_l(&req.n, sizeof(req), IFLA_LINK,
>>&ifindex, 4);
>> -               }
>>         }
>>
>>         if (name) {
>> --
>> 1.7.5.4
>>
>
