From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Debugging TCP: Treason Uncloaked
Date: Tue, 20 May 2008 13:17:40 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0805201142190.16829@wrl-59.cs.helsinki.fi>
References: <482265A0.8040105@redhat.com> <Pine.LNX.4.64.0805121637560.1888@wrl-59.cs.helsinki.fi>
 <4831AD87.1040909@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, johnwheffner@gmail.com
To: Chris Bredesen <cbredesen@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:41784 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753649AbYETKRo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2008 06:17:44 -0400
In-Reply-To: <4831AD87.1040909@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 19 May 2008, Chris Bredesen wrote:

> Kernel on the NAS device is 2.6.9 AFAIK but the distro has proprietary bits in
> it so I'm not sure what's been done there.  It's a Netgear ReadyNAS appliance.

It well could be NAS' fault as well.... The recent case with 25-rcs had 
TCP to transmit _past_ snd_nxt (ie., too far, which of course is not right 
either), not that the window was actually shrunk as the message suggests.

> In any case, I'm attaching an archive of the whole tcpdump session so you can
> have a look.   Please let me know if you need more info. 

Hmm, this actually seems to be fault of that type in NAS' TCP:

20:06:57.976848 ... > nas.rsync: . 23744483:23745931(1448) ack 130667 win 1448 
20:06:57.977241 nas.rsync > ...: . 130667:132115(1448) 
20:06:57.977294 nas.rsync > ...: . 132115:133563(1448) 
20:06:57.977308 nas.rsync > ...: P 133563:134259(696)

How come could it send 134259 when advertized window is just 130667+1448 = 
132115 and assume that to work? Then TCP at NAS' end finally gives up 
later because it does get cumulative ACK as response to a number of RTOs 
as window remains zero at 133563. Would the window open from zero, the 
situation would resolve when RTO is received. But it doesn't which 
may be client side user-space application's "fault" as it seems to not be 
too eager to read from TCP(?) :-/, nevertheless, NAS violated spec and 
cannot cope the results. And yes, the client didn't shrink the window 
anywhere (I checked that too), so those transmission are obviously out of 
window by spec.

If some other client works, it may be just due to luck, eg., user-space 
works differently or a subtle difference in TCP implementation behavior.

As a workaround, one could try larger receiver buffer at the client.
I don't think window scaling contributes to this problem as you suggested 
earlier, except that there are some bugs related to it in 2.6.9 that are 
fixed now (and even 2.6.24 might have the rounding bug unless somebody 
sent that to stable, I don't remember if that happened, that is, commit 
607bfbf2d55dd1cfe5368b41c2a81a8c9ccf4723).

-- 
 i.
