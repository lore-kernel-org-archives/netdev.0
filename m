From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next 03/12] i40e: Handle a single mss packet with more
 than 8 frags
Date: Tue, 18 Nov 2014 06:33:21 -0800
Message-ID: <1416321201.14060.20.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1416031715-32498-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1416031715-32498-4-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1416075695.17262.86.camel@edumazet-glaptop2.roam.corp.google.com>
	 <FC41C24E35F18A40888AACA1A36F3E418AD8F543@fmsmsx115.amr.corp.intel.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1C9F1F9F@AcuExch.aculab.com>
	 <1416243484.5102.21.camel@edumazet-glaptop2.roam.corp.google.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1C9F290B@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "'Nelson, Shannon'" <shannon.nelson@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Kong, Serey" <serey.kong@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:40896 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755252AbaKROdY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2014 09:33:24 -0500
Received: by mail-ie0-f181.google.com with SMTP id tp5so4610584ieb.12
        for <netdev@vger.kernel.org>; Tue, 18 Nov 2014 06:33:23 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1C9F290B@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-11-18 at 09:46 +0000, David Laight wrote:

> That isn't entirely clear from the patch context.

gso_segs = 1 was not clear ???

gso_segs = 1;
if (skb_shinfo(skb)->nr_frags >= I40E_MAX_BUFFER_TXD)
	skb_linearize(skb);


Nelson, what happens if a packet has 2 segments and uses 17 fragments ?
Is the hardware OK with that ?

netperf -t TCP_SENDFILE -- -m 171

I did the test and it seems fine on my host, but maybe it was pure luck.

While the following indeed froze the card :

netperf -H 7.7.7.27 -t TCP_SENDFILE -- -m 30


[3257268.702689] i40e 0000:84:00.0: requesting a pf reset
[3257268.831786] i40e 0000:84:00.0: i40e_ptp_init: added PHC on eth2
[3257268.912798] i40e 0000:84:00.0 eth2: NIC Link is Up 40 Gbps Full Duplex, Flow Control: RX/TX
[3257338.895753] i40e 0000:84:00.0: Detected Tx Unit Hang
[3257338.895753]   VSI                  <518>
[3257338.895753]   Tx Queue             <16>
[3257338.895753]   next_to_use          <17c>
[3257338.895753]   next_to_clean        <b2>
[3257338.895757] i40e 0000:84:00.0: tx_bi[next_to_clean]
[3257338.895757]   time_stamp           <1c20f09c9>
[3257338.895757]   jiffies              <1c20f0eac>
[3257338.895759] i40e 0000:84:00.0: tx hang detected on queue 16, resetting adapter
[3257338.895769] i40e 0000:84:00.0 eth2: tx_timeout recovery level 1
[3257338.895926] i40e 0000:84:00.0: i40e_vsi_control_tx: VSI seid 518 Tx ring 0 disable timeout
[3257338.949922] i40e 0000:84:00.0: i40e_vsi_control_tx: VSI seid 520 Tx ring 64 disable timeout
[3257339.410705] i40e 0000:84:00.0: PF reset failed, -15

> 
> For a non-TSO packet the skb_serialize() is less likely to fail
> since it doesn't need contiguous pages.

Any memory allocation can fail, regardless of the size.
We do not want a memory stress being able to crash the host,
likely or not. It is not worth discussing this, really.
