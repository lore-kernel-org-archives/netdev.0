From: Joseph Gasparakis <joseph.gasparakis@intel.com>
Subject: Re: issues with vxlan RX checksum offload under OVS datapath
Date: Tue, 21 Jan 2014 13:47:33 -0800 (PST)
Message-ID: <alpine.LFD.2.03.1401211336550.16080@intel.com>
References: <52DC4C1B.5000309@mellanox.com> <CALnjE+rUTejbU_d39G7WSn=k0aY2xELCE3UxjDr_Zdq3iwHbNA@mail.gmail.com> <CAJZOPZJ6xj=fOAY9rkXZZs99ONkHwcW8RMXb+H2FjJzV3eoAPg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Pravin Shelar <pshelar@nicira.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Joseph Gasparakis <joseph.gasparakis@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:8291 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753745AbaAUV3n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jan 2014 16:29:43 -0500
In-Reply-To: <CAJZOPZJ6xj=fOAY9rkXZZs99ONkHwcW8RMXb+H2FjJzV3eoAPg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Tue, 21 Jan 2014, Or Gerlitz wrote:

> On Tue, Jan 21, 2014 at 7:30 PM, Pravin Shelar <pshelar@nicira.com> wrote:
> > On Sun, Jan 19, 2014 at 2:05 PM, Or Gerlitz <ogerlitz@mellanox.com> wrote:
> 
> >> While testing the gro udp patches over a setup with openvswitch I noted that
> >> the RX checksum offload support introduced by Joseph's commit 0afb166
> >> "vxlan: Add capability of Rx checksum offload for inner packet" works fine
> >> when you use a setup made of
> >> NIC --> IP stack --> vxlan device --> bridge --> tap
> >> but not when its
> >> NIC --> IP stack --> ovs vxlan port --> OVS DP --> tap
> >> I narrowed it down to the fact the when going the OVS pathskb->encapsulation
> >> remains true also after the decap is done. Basically, this is the original hunk
> [...]
> >>> +       skb->encapsulation = 0;
> [...]
> 
> >> Moving this to shared code (while removing the check for
> >> vxlan->dev->features) made things to work on my setup, but this misses one
> >> of the original conditions, ideas?
> 
> > I kept csum check in vxlan-device recv path for same reason. As of now
> > there is no efficient way to get ovs-dev features.
> > May be we can cache device features in struct datapath from datapath-netdev.
> 
> To be a bit more precise/concrete here, do we agree that the both paths must do
> 
>    skb->encapsulation = 0;
> 
> which is done now only by the non-ovs path

Originally skb->encapsulation had (and still has) the meaning of "does 
this skb have outer *and* (valid) inner headers? If so, it is an 
encapsulated packet". 
So based on this skb->encapsulation should be set as soon an (inner) 
packet gets encapsulated and unset when decapsulation takes place, and 
ideally this should happen in the ovs path too. Together with 
skb->encapsulation the inner headers should be correctly set.
 
> 
> Or.
> 
