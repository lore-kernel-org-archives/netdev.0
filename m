From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [ethtool PATCH] ethtool: Resolve use of uninitialized memory in
 rxclass_get_dev_info
Date: Mon, 16 Jul 2012 21:03:37 +0100
Message-ID: <1342469017.2523.33.camel@bwh-desktop.uk.solarflarecom.com>
References: <20120713165221.28140.92681.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <jeffrey.t.kirsher@intel.com>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:32357 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752991Ab2GPUDk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2012 16:03:40 -0400
In-Reply-To: <20120713165221.28140.92681.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-07-13 at 09:55 -0700, Alexander Duyck wrote:
> The ethtool function for getting the rule count was not zeroing out the
> data field before passing it to the kernel.  As a result the value started
> uninitialized and was incorrectly returning a result indicating that
> devices supported setting new rule indexes.  In order to correct this I am
> adding a one line fix that sets data to zero before we pass the command to
> the kernel.

Right.  For 'get' commands with no parameters (besides the device) the
data copied back to userland is normally zero-initialised and then
filled out by the driver, and I seem to have worked on that assumption.
But because of the odd multiplexing of RX NFC commands
ETHTOOL_GRXCLSRLCNT doesn't work like that.  And for 'my' driver that
didn't matter.  Sorry about that.

(We should really have some explicit documentation of responsibility for
structure initialisation.)

> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> ---
> 
> I am resending this since I didn't see any notification that it had been seen.
> I also realized that I had not clearly identified that this is an ethtool user
> space patch and not an ethtool kernel space patch.

It was perfectly clear and I had queued it up to review but hadn't yet
done so.

Ben.

>  rxclass.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/rxclass.c b/rxclass.c
> index 4d49aa6..e1633a8 100644
> --- a/rxclass.c
> +++ b/rxclass.c
> @@ -207,6 +207,7 @@ static int rxclass_get_dev_info(struct cmd_context *ctx, __u32 *count,
>  	int err;
>  
>  	nfccmd.cmd = ETHTOOL_GRXCLSRLCNT;
> +	nfccmd.data = 0;
>  	err = send_ioctl(ctx, &nfccmd);
>  	*count = nfccmd.rule_cnt;
>  	if (driver_select)
> 

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
