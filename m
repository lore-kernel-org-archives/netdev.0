From: stephen@dino.dnsalias.com (Stephen J. Bevan)
Subject: Re: [RFC] Ethernet Cheap Cryptography
Date: Wed, 18 Oct 2006 20:57:52 -0700
Message-ID: <17718.63424.509719.492216@localhost.localdomain>
References: <200610151820.22867.dpc@asn.pl>
	<17717.40394.531846.695392@localhost.localdomain>
	<200610181115.12471.dpc@asn.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Stephen J. Bevan" <stephen@dino.dnsalias.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from S010600014e000000.vc.shawcable.net ([70.79.40.36]:62185 "EHLO
	dino.dnsalias.com") by vger.kernel.org with ESMTP id S1945893AbWJSD6z
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Oct 2006 23:58:55 -0400
To: Dawid Ciezarkiewicz <dpc@asn.pl>
In-Reply-To: <200610181115.12471.dpc@asn.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dawid Ciezarkiewicz writes:
 > You're right. I'll add such documentation. For now - short version: as a 
 > company dealing with wifi regularly we often come to a problem - using wifi 
 > bridges with strengths like price, "CE included", easy integration, good 
 > bandwidth, distance etc. - that those devices regularly have max eth mtu 
 > 1500, not much cpu power and are often so feature-less that there are many 
 > problems with good traffic security.

So far so good.


 > It enforces to use upper level encryption with internal
 > fragmentation which is problem because of more more frames that
 > those bridges have to handle, bigger traffic etc. 

Where did the fragmentation come from?  If you are sending TCP over
IPsec then the ESP/AH code should decrease the TCP MSS as it goes
through to take acount of the extra space that IPsec will take up.
Thus neither end-point will ever send a frame on that session that
will require fragmentation.  Granted you can still have a problem if
someone sends a UDP packet that is close to the 1500 MTU, but RFCs
recommend against it (e.g. DNS&SIP) and applications should try to
avoid it.

Thus the argument for ccrypt should say :-

a) why IPsec is not suitable for securing IP traffic in WIFI scenarios.

b) what traffic other than IP traffic needs to be encrypted.


 > Well - ccrypt allows to change keys without disrupting traffic. It
 > works like this: first new ccrypt_rx alg:key pair is added. After
 > that ccrypt_rx will still use old alg:key, but all unmatched frames
 > will be challenged against new one too. Then as soon as possible
 > ccrypt_tx should have that new alg:key pair added. When ccrypt_rx
 > gets new frame sent by new alg:key it will not match old alg:key,
 > but will match new one. Receiver will switch then and from now on
 > it will use only new pair.

And if the packets come out of order i.e. you get a packet with a new
key followed by a packet with the old key?


 > This allows key switching without loosing any frames. It should be done 
 > quickly, since when in "key transition" state all invalid/spoofed
 > frames have  double cpu impact on receiver. Shouldn't be a problem
 > because attacker should have no clue about when key is being switched.

If the keying is done manually an attacker won't know when the keys
are changed.  However, if keying is coordinated over the same link via
a protocol (as is done with IKE for IPsec) then the attacker can see
(or at least guess) the packets carrying the keying protcol thus know
re-keying is going to occur.


 > As device ccrypt_rx and tx are independent traffic encryption can use 
 > independent keys in both traffic directions. And because they use pairs of 
 > alg:key, in each change: algorithm, key and key length can be changed at 
 > once. AFAIK attacker have no way to tell where such change occurs nor what 
 > are parameters of current alg:key.
 > 
 > The idea is to change keys regularly on both sides with userspace
 > tools - like ssh on separate vlan, or even simpler static key
 > rotation algorithms or something like it. This should allow secure
 > alg:key switching with about any  frequency.

Indeed, in IPsec, the equivalent of ccrypt is ESP and that's rather
straighforward.  The complicated part is IKE, the userspace component
that handles keying.  It is certainly possible to create something
simpler than IKE (e.g. IKEv2 is somewhat simpler) but the devil is in
the details.


 > I was not aware of that. Thanks. I will add this info to
 > documentation. There is nothing actually I can do about that in the
 > form that ccrypt is mean to be now.

For completness there are also switches that :-

* take notice of the TOS/DiffServ bits in an IP header and will
  re-order based on them 

* will re-order frames due to redundancy, load-balancing,
  spanning-tree changes ... etc.
