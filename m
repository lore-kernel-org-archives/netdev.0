From: jamal <hadi@cyberus.ca>
Subject: Re: Question about an assignment in handle_ing()
Date: Sun, 30 May 2010 09:29:10 -0400
Message-ID: <1275226150.3587.9.camel@bigi>
References: <20100524112236.GF2810@psychotron.lab.eng.brq.redhat.com>
	 <1274781067.3878.872.camel@bigi>
	 <20100525102603.GA11494@gondor.apana.org.au>
	 <1274789024.3878.919.camel@bigi>
	 <20100525121202.GA12712@gondor.apana.org.au>
	 <1274790038.3878.926.camel@bigi>
	 <20100525124636.GA13161@gondor.apana.org.au>
	 <1274793216.3878.947.camel@bigi>
	 <20100525231307.GA19475@gondor.apana.org.au>
	 <1274873881.3878.988.camel@bigi>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-jX0Ixn8dusrxslgBYw3/"
Cc: Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, kaber@trash.net
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:50705 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753690Ab0E3N3Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 May 2010 09:29:16 -0400
Received: by vws11 with SMTP id 11so1042677vws.19
        for <netdev@vger.kernel.org>; Sun, 30 May 2010 06:29:15 -0700 (PDT)
In-Reply-To: <1274873881.3878.988.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-jX0Ixn8dusrxslgBYw3/
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Wed, 2010-05-26 at 07:38 -0400, jamal wrote:
> On Wed, 2010-05-26 at 09:13 +1000, Herbert Xu wrote:
> 
> > If it did happen like you said then it would be a serious bug
> > in our stack as everything else (including the TCP stack) relies
> > on this.
> 
> It could have been a bug. Note this was not a simple test, so there
> may be other factors involved. If you or Jiri are willing to run the
> test i will construct a scenario which will test this out. It will need
> a compile of the kernel and a small check in pedit to see if we see
> cloned skbs when we run the two tcpdumps (and to make sure the tcpdumps
> see the correct bytes). Otherwise i will get to it by weekend.

I have constructed a test case (attached) and my fear is unfortunately
still there;-< What am i doing wrong?

The packet path is:
-->eth0-->tcpdump eth0-->pedit-->mirror to dummy0-->tcpdump dummy0

I expect pedit to see a cloned packet. It doesnt. The check is in
tcf_pedit(), just before "if (!(skb->tc_verd & TC_OK2MUNGE))"
added: 
printk("pedit: skb-%p is %s\n",skb,skb_cloned(skb)?"cloned":"!cloned");

Is pf packet not cloning etc? Sorry, I dont have much time today
to dig into the code - but i figure youd know the answer.

> > But how can the caller make that decision when you return exactly
> > the same value in the error case as the normal case?
> 
> Ok - i see your point Herbert ;-> 
> it makes sense to have pedit have an error action code like some of the
> others actions which defaults to a drop.
> I will do a proper patch sometime this weekend.

I will get it done this week.

cheers,
jamal

--=-jX0Ixn8dusrxslgBYw3/
Content-Disposition: attachment; filename="jiri-q-test"
Content-Type: text/plain; name="jiri-q-test"; charset="UTF-8"
Content-Transfer-Encoding: 7bit


machine running script is 10.0.0.111 receiving on eth0.
We are pinging from 10.0.0.26 to 10.0.0.111.
On 10.0.0.111:
1)Edit the packet when it comes in to change src/dst mac addresses
2)Mirror copy to dummy0 

mirror to dummy0 is useful for debugging (ifconfig shows you stats and you
can run tcpdump to log the copies as we do)

run tcpdump before #1 and after #1 - this way we see the original
packet at eth0 and the modified packet at dummy0.

-------------- start script on 10.0.0.111 -----
tc qdisc del dev eth0 ingress     
tc qdisc add dev eth0 ingress     
ifconfig dummy0 up
tc filter add dev eth0 parent ffff: protocol ip prio 10 u32 \
match ip protocol 1 0xff flowid 1:2 \
action pedit \
munge offset -12 u32 set 0x00010100 \
munge offset -8 u32 set 0x0aaf0100 \
munge offset -4 u32 set 0x00080800 pipe \
action mirred egress mirror dev dummy0
------

To validate you did this right, dumping should look as follows:
----
filter protocol ip pref 10 u32 
filter protocol ip pref 10 u32 fh 800: ht divisor 1 
filter protocol ip pref 10 u32 fh 800::800 order 2048 key ht 800 bkt 0 flowid 1:2 
  match 00010000/00ff0000 at 8
	action order 1:  pedit action pipe keys 3
 	 index 1 ref 1 bind 1
	 key #0  at -12: val 00010100 mask 00000000
	 key #1  at -8: val 0aaf0100 mask 00000000
	 key #2  at -4: val 00080800 mask 00000000
 
	action order 2: mirred (Egress Mirror to device dummy0) pipe
 	index 1 ref 1 bind 1
-----

tcpdump on dummy0 (showing modified macs):
 
0a:af:01:00:00:08 > 52:54:00:01:01:00, ethertype IPv4 (0x0800), length 98: 10.0.0.26 > 10.0.0.111: ICMP echo request, id 5981, seq 1, length 64
	0x0000:  4500 0054 0000 4000 4001 2621 0a00 001a
	0x0010:  0a00 006f 0800 a951 175d 0001 d3c8 fa4b
	0x0020:  0000 0000 9d68 0d00 0000 0000 1011 1213
	0x0030:  1415 1617 1819 1a1b 1c1d 1e1f 2021 2223
	0x0040:  2425 2627 2829 2a2b 2c2d 2e2f


--=-jX0Ixn8dusrxslgBYw3/--

