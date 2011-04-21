From: Michal Simek <monstr@monstr.eu>
Subject: Re: Hight speed data sending from custom IP out of kernel
Date: Thu, 21 Apr 2011 11:20:47 +0200
Message-ID: <4DAFF6EF.2080705@monstr.eu>
References: <53f539ea861e1a24bde4aadceff0b3bb.squirrel@www.liukuma.net>	 <4DAD76F1.40309@monstr.eu>	 <45cb2254ff23a4977c95b0f9459e39a6.squirrel@www.liukuma.net>	 <4DAFE4A0.2030905@monstr.eu> <1303373925.3685.6.camel@edumazet-laptop>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: juice@swagman.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:37785 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751318Ab1DUJUw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2011 05:20:52 -0400
Received: by fxm17 with SMTP id 17so832174fxm.19
        for <netdev@vger.kernel.org>; Thu, 21 Apr 2011 02:20:50 -0700 (PDT)
In-Reply-To: <1303373925.3685.6.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Le jeudi 21 avril 2011 =C3=A0 10:02 +0200, Michal Simek a =C3=A9crit =
:
>=20
>> Thanks for that. I am looking at pktgen. On UDP my system is able to=
 send full=20
>> bandwidth on 100Mbit/s ethernet and 220Mbit/s on 1G/s.
>> I will let you know when I have any useful resutls.
>=20
> 220Mbits/s in pktgen or an application ?
> - how many packets per second ? (or packet size ?)

pktgen - Packet size 1500 on 1Gb/s lan - 66MHx Microblaze cpu without h=
wcsum=20
support.

~ # cat /proc/net/pktgen/eth0
Params: count 10000000  min_pkt_size: 1500  max_pkt_size: 1500
      frags: 0  delay: 0  clone_skb: 1000000  ifname: eth0
      flows: 0 flowlen: 0
      queue_map_min: 0  queue_map_max: 0
      dst_min: 192.168.0.102  dst_max:
         src_min:   src_max:
      src_mac: 00:0a:35:00:8d:0d dst_mac: 00:12:79:c0:59:15
      udp_src_min: 9  udp_src_max: 9  udp_dst_min: 9  udp_dst_max: 9
      src_mac_count: 0  dst_mac_count: 0
      Flags:
Current:
      pkts-sofar: 254875  errors: 0
      started: 729900351us  stopped: 743064495us idle: 26885us
      seq_num: 254876  cur_dst_mac_offset: 0  cur_src_mac_offset: 0
      cur_saddr: 0xc0a80073  cur_daddr: 0xc0a80066
      cur_udp_dst: 9  cur_udp_src: 9
      cur_queue_map: 0
      flows: 0
Result: OK: 13164144(c13137258+d26885) nsec, 254875 (1500byte,0frags)
   19361pps 232Mb/sec (232332000bps) errors: 0

>=20
> pktgen has the "clone_skb 100" thing that avoid skb_alloc()/skb_free(=
)
> overhead, and permits to really test driver performance.
>=20
> It also bypass qdisc management.

I have also tried to removed fragments support from the driver to find =
out what=20
happen if I remove the part of code from xmit path and there is improve=
ment.

~ # cat /proc/net/pktgen/eth0
Params: count 10000000  min_pkt_size: 1500  max_pkt_size: 1500
      frags: 0  delay: 0  clone_skb: 1000000  ifname: eth0
      flows: 0 flowlen: 0
      queue_map_min: 0  queue_map_max: 0
      dst_min: 192.168.0.102  dst_max:
         src_min:   src_max:
      src_mac: 00:0a:35:00:8d:0d dst_mac: 00:12:79:c0:59:15
      udp_src_min: 9  udp_src_max: 9  udp_dst_min: 9  udp_dst_max: 9
      src_mac_count: 0  dst_mac_count: 0
      Flags:
Current:
      pkts-sofar: 2041908  errors: 0
      started: 45216342us  stopped: 146752402us idle: 135633us
      seq_num: 2041909  cur_dst_mac_offset: 0  cur_src_mac_offset: 0
      cur_saddr: 0xc0a80073  cur_daddr: 0xc0a80066
      cur_udp_dst: 9  cur_udp_src: 9
      cur_queue_map: 0
      flows: 0
Result: OK: 101536059(c101400425+d135633) nsec, 2041908 (1500byte,0frag=
s)
   20110pps 241Mb/sec (241320000bps) errors: 0


I have also tested frags support and here are results for above configu=
ration.
frags 0 =3D 232Mb/s
frags 1 =3D 192Mb/s
frags 2 =3D 159Mb/s
frags 3 =3D 141Mb/s
frags 4 =3D 130Mb/s
frags 5 =3D 116Mb/s

The eth controller generate irq when tx is done. I measured it yesterda=
y and it=20
takes 810 timer ticks to send data (1.5k packet size). It is hard to ex=
pect how=20
many cpu instructions it is but maybe half that's why I want to try to =
disable=20
IRQ generation and wait when DMA copy is done. Do I have any other opti=
ons?

Thanks,
Michal

--=20
Michal Simek, Ing. (M.Eng)
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel 2.6 Microblaze Linux - http://www.monstr.eu/=
fdt/
Microblaze U-BOOT custodian
