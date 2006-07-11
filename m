From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: ipsec tunnel asymmetrical mtu
Date: Tue, 11 Jul 2006 11:31:33 +0200
Message-ID: <BAY103-F36F59C0E4B463B590831A5B2680@phx.gbl>
References: <BAY103-F209936DACD91675B1D73DFB2680@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc1-s16.bay0.hotmail.com ([65.54.246.88]:22440 "EHLO
	bay0-omc1-s16.bay0.hotmail.com") by vger.kernel.org with ESMTP
	id S1750818AbWGKJbf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jul 2006 05:31:35 -0400
In-Reply-To: <BAY103-F209936DACD91675B1D73DFB2680@phx.gbl>
To: herbert@gondor.apana.org.au
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Marco Berizzi wrote:

>Herbert Xu wrote:
>
>>On Mon, May 08, 2006 at 08:28:32AM +0000, Marco Berizzi wrote:
>> >
>> > root@Mimosa:~# ping 10.49.59.23
>> > PING 10.49.59.23 (10.49.59.23) 56(84) bytes of data.
>> > 64 bytes from 10.49.59.23: icmp_seq=1 ttl=247 time=91.9 ms
>> > 64 bytes from 10.49.59.23: icmp_seq=2 ttl=247 time=49.3 ms
>> > 64 bytes from 10.49.59.23: icmp_seq=3 ttl=247 time=106 ms
>> > 64 bytes from 10.49.59.23: icmp_seq=4 ttl=247 time=74.3 ms
>> >
>> > --- 10.49.59.23 ping statistics ---
>> > 4 packets transmitted, 4 received, 0% packet loss, time 2998ms
>> > rtt min/avg/max/mdev = 49.316/80.460/106.257/21.241 ms
>> > root@Mimosa:~# cd /tmp/
>> > root@Mimosa:/tmp# tcpdump -v -p -n ip host 10.49.59.23 >
>> > /tmp/NULL-10.49.59.23 &
>> > [1] 18981
>> > root@Mimosa:/tmp# tcpdump: listening on eth0, link-type EN10MB 
>>(Ethernet),
>> > capture size 96 bytes
>> >
>> > root@Mimosa:/tmp# ping 10.49.59.23
>> > PING 10.49.59.23 (10.49.59.23) 56(84) bytes of data.
>> >
>> > --- 10.49.59.23 ping statistics ---
>> > 8 packets transmitted, 0 received, 100% packet loss, time 6999ms
>> >
>> > root@Mimosa:/tmp# fg
>> > tcpdump -v -p -n ip host 10.49.59.23 >/tmp/NULL-10.49.59.23
>> > 101 packets captured
>> > 101 packets received by filter
>> > 0 packets dropped by kernel
>>
>>Yes this is really weird.  The only thing I can think of is that it
>>somehow managed to put some bogus entry into the conntrack table.
>>What happens if you do
>>
>>grep 10.49.59.23 /proc/net/ip_conntrack
>>
>>before and after the tcpdump?
>
>I'm not able to reproduce it :-[[[
>Today mimosa is running 2.6.17.4, mon May 8 mimosa was running
>2.6.16.12
>
>If you want I could downgrade to 2.6.16.12 and see if I'm able
>to reproduce it.
>Sorry.

Me again. After a while here is:

root@Mimosa:/tmp# ping 10.49.59.23
PING 10.49.59.23 (10.49.59.23) 56(84) bytes of data.

--- 10.49.59.23 ping statistics ---
4 packets transmitted, 0 received, 100% packet loss, time 3010ms

root@Mimosa:/tmp# grep 10.49.59.23 /proc/net/ip_conntrack
tcp      6 431889 ESTABLISHED src=172.16.0.167 dst=10.49.59.23 sport=1142 
dport=3218 packets=27 bytes=3559 src=10.49.59.23 dst=172.29.128.1 sport=3218 
dport=1142 packets=37 bytes=38629 [ASSURED] mark=0 use=1
root@Mimosa:/tmp# ping 10.49.59.23
PING 10.49.59.23 (10.49.59.23) 56(84) bytes of data.

--- 10.49.59.23 ping statistics ---
13 packets transmitted, 0 received, 100% packet loss, time 11999ms

root@Mimosa:/tmp# grep 10.49.59.23 /proc/net/ip_conntrack
tcp      6 431868 ESTABLISHED src=172.16.0.167 dst=10.49.59.23 sport=1142 
dport=3218 packets=27 bytes=3559 src=10.49.59.23 dst=172.29.128.1 sport=3218 
dport=1142 packets=37 bytes=38629 [ASSURED] mark=0 use=1
root@Mimosa:/tmp# tcpdump -v -p -n ip host 10.49.59.23 > HERBERT-20060711 &
[1] 4747
root@Mimosa:/tmp# tcpdump: listening on eth0, link-type EN10MB (Ethernet), 
capture size 96 bytes

root@Mimosa:/tmp# grep 10.49.59.23 /proc/net/ip_conntrack
tcp      6 431853 ESTABLISHED src=172.16.0.167 dst=10.49.59.23 sport=1142 
dport=3218 packets=27 bytes=3559 src=10.49.59.23 dst=172.29.128.1 sport=3218 
dport=1142 packets=37 bytes=38629 [ASSURED] mark=0 use=1
root@Mimosa:/tmp# ping 10.49.59.23
PING 10.49.59.23 (10.49.59.23) 56(84) bytes of data.

--- 10.49.59.23 ping statistics ---
9 packets transmitted, 0 received, 100% packet loss, time 8026ms

root@Mimosa:/tmp# grep 10.49.59.23 /proc/net/ip_conntrack
tcp      6 431837 ESTABLISHED src=172.16.0.167 dst=10.49.59.23 sport=1142 
dport=3218 packets=27 bytes=3559 src=10.49.59.23 dst=172.29.128.1 sport=3218 
dport=1142 packets=37 bytes=38629 [ASSURED] mark=0 use=1
root@Mimosa:/tmp# fg
tcpdump -v -p -n ip host 10.49.59.23 >HERBERT-20060711
9 packets captured
9 packets received by filter
0 packets dropped by kernel
root@Mimosa:/tmp# cat HERBERT-20060711
11:23:48.981383 IP (tos 0x0, ttl 248, id 27422, offset 0, flags [none], 
length: 84) 10.49.59.23 > 172.29.128.1: icmp 64: echo reply seq 1
11:23:49.983515 IP (tos 0x0, ttl 248, id 27426, offset 0, flags [none], 
length: 84) 10.49.59.23 > 172.29.128.1: icmp 64: echo reply seq 2
11:23:50.983110 IP (tos 0x0, ttl 248, id 27521, offset 0, flags [none], 
length: 84) 10.49.59.23 > 172.29.128.1: icmp 64: echo reply seq 3
11:23:51.994398 IP (tos 0x0, ttl 248, id 27523, offset 0, flags [none], 
length: 84) 10.49.59.23 > 172.29.128.1: icmp 64: echo reply seq 4
11:23:52.999726 IP (tos 0x0, ttl 248, id 27525, offset 0, flags [none], 
length: 84) 10.49.59.23 > 172.29.128.1: icmp 64: echo reply seq 5
11:23:53.999583 IP (tos 0x0, ttl 248, id 27529, offset 0, flags [none], 
length: 84) 10.49.59.23 > 172.29.128.1: icmp 64: echo reply seq 6
11:23:54.999584 IP (tos 0x0, ttl 248, id 27531, offset 0, flags [none], 
length: 84) 10.49.59.23 > 172.29.128.1: icmp 64: echo reply seq 7
11:23:56.013499 IP (tos 0x0, ttl 248, id 27554, offset 0, flags [none], 
length: 84) 10.49.59.23 > 172.29.128.1: icmp 64: echo reply seq 8
11:23:57.000901 IP (tos 0x0, ttl 248, id 27936, offset 0, flags [none], 
length: 84) 10.49.59.23 > 172.29.128.1: icmp 64: echo reply seq 9

root@Mimosa:/tmp#


