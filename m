From: gerrit@erg.abdn.ac.uk
Subject: Re: [PATCH 4/5] Adds options DROPPED PACKETS and LOSS INTERVALS to
      receiver
Date: Sat, 19 Sep 2009 14:16:08 +0100 (BST)
Message-ID: <7016.72.11.80.242.1253366168.squirrel@72.11.80.242>
References: <4AA6A267.7080500@embedded.ufcg.edu.br>
    <20090913184128.GA7165@gerrit.erg.abdn.ac.uk>
    <cb00fa210909141740u585116c7i45165054d741a022@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Gerrit Renker" <gerrit@erg.abdn.ac.uk>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
To: "Ivo Calado" <ivocalado@embedded.ufcg.edu.br>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:53840 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753231AbZISNQM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Sep 2009 09:16:12 -0400
In-Reply-To: <cb00fa210909141740u585116c7i45165054d741a022@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> | Adds options DROPPED PACKETS and LOSS INTERVALS to receiver.
I must admit that I did not look at this deeply enough to be able to
say whether it would work or not. The comments that were sent were afte=
r
the first reading.

Whether to add the Loss Intervals / Dropped Packet options is related t=
o
the question in patch 2/5. This needs to be clarified first: you do add
the Loss Intervals option, but if you do it, the division of the loss
intervals is not necessary - unless I am missing something here, this
computation is done by the sender.

If I understand RFC 4342/4828/5622 correctly, the sender would need to
keep track of the RTTs for each sent loss interval. Since the loss
interval boundaries are set by the receiver, the sender would need to
store the window counter value (or the RTT). RFC 4828 is a bit misleadi=
ng
since it quotes RFC 3448/5348 (where the receiver computes the loss
event rate), whereas CCID-4 is based on RFC 4342 (where the sender
normally computes the loss event rate).



>> The condition above should be '&&', not '||'. Suggested alternative:
>>
>> + =A0 =A0 =A0 if (tfrc_lh_slab =3D=3D NULL)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto lh_failed;
>> +
>> + =A0 =A0 =A0 tfrc_ld_slab =3D kmem_cache_create("tfrc_sp_li_data",
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0sizeof(struct
>> tfrc_loss_data_entry), 0,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0SLAB_HWCACHE_ALIGN, NULL);
>> + =A0 =A0 =A0 if (tfrc_ld_slab !=3D NULL)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>> +
>> + =A0 =A0 =A0 kmem_cache_destroy(tfrc_lh_slab);
>> + =A0 =A0 =A0 tfrc_lh_slab =3D NULL;
>> +lh_failed:
>> + =A0 =A0 =A0 return -ENOBUFS;
>> =A0}
>>
>
> Thanks for revising this. Adding one label for each failure case will
> not scale well. In another patch it will be needed to create another
> structure, and so, requiring another label.
Using such labels follows a coding convention in the networking code.
As an example, consider ip4_init_mib_net() in net/ipv4/af_inet.c.

The pattern is that if step n fails, it does a rollback, undoing all
preceding initialisations in the reverse order. I think this is also
in agreement with Documentation/CodingStyle, chap. 7.




> And how would be to determine if one packet's ecn is set to ECT 0 or =
ECT
> 1?
It should be possible to use '=3D=3D' directly, i.e.
switch (DCCP_SKB_CB(skb)->dccpd_ecn) {
case  INET_ECN_NOT_ECT:  // ECN not enabled
case  INET_ECN_ECT_1:    // ECT(1), see below
case  INET_ECN_ECT_0:    // ECT(0)
case  INET_ECN_CE:       // congestion
}

However, the kernel currently only supports ECT(0). Resolving this is
ongoing work in another thread. For the moment, it simplifies the ECN
nonce verification; as per figure 1 in RFC 3540, the sum will always
be 0 if only ECT(0) is used.

This would allow to write a function stub for ECN nonce verification,
which for the moment only does something like

bool dccp_verify_ecn_nonce(const u8 sum)
{
      return sum =3D=3D 0;
}

The same "fix" has currently been put into the Ack Vector nonce sum,
this is in
http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=3Ddccp_exp.git;\
a=3Dcommitdiff;h=3D50e6081f6ff37102ac5f92df85f017e2c15f338a

