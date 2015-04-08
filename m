From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH] e1000e: Cleanup handling of VLAN_HLEN as a part of max
 frame size
Date: Wed, 08 Apr 2015 15:58:54 -0700
Message-ID: <5525B2AE.80301@gmail.com>
References: <alpine.NEB.2.11.1504081019220.3388@chris.i8u.org> <20150408204630.4643.37880.stgit@ahduyck-vm-fedora22> <alpine.NEB.2.11.1504081413510.3388@chris.i8u.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, mike@cchtml.com
To: Hisashi T Fujinaka <htodd@twofifty.com>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:34335 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753681AbbDHW65 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 18:58:57 -0400
Received: by pdbqa5 with SMTP id qa5so73604377pdb.1
        for <netdev@vger.kernel.org>; Wed, 08 Apr 2015 15:58:57 -0700 (PDT)
In-Reply-To: <alpine.NEB.2.11.1504081413510.3388@chris.i8u.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/08/2015 02:15 PM, Hisashi T Fujinaka wrote:
> On Wed, 8 Apr 2015, Alexander Duyck wrote:
>
>> Fixes: c751a3d58cf2d ("e1000e: Correctly include VLAN_HLEN when
>> changing interface MTU")
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
>> ---
>>
>> I have only build tested this though I am 99% sure the fixes here are
>> correct.  This patch should fix issues on 82573 and ich8 w/ setting
>> an MTU
>> of 1500, and for the PCH series w/ setting an MTU of 9000.
>
> Since the original fix was something submitted by Red Hat, can you check
> that you're not re-breaking whatever it was that Red Hat thought they
> were fixing?

The original issue is referenced in the patch that this fixes.  The
problem was that the VLAN header wasn't being considered when computing
the Rx buffer size, so you could change the MTU to 1504 and the if
statement at the end of e1000_change_mtu was still using a 1522 Rx
buffer size and max frame even though we had technically just configured
things for 1526.

The updated logic is correctly taking the VLAN header into account so if
you bump the MTU 1504 it will switch over to jumbo frames mode w/ 2K
buffers.

The bit I am fixing is that there were several spots including the
backend value for max_hw_frame_size that didn't take VLAN header length
into account.  There were cases where 1500 MTU was being treated as a
jumbo frame, or we were coming up 4 bytes shy as in the pch2, ich8, and
82573 e1000_info structures.

- Alex
