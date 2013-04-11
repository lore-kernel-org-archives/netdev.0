From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2 net-next] ptp: dynamic allocation of PHC char devices
Date: Thu, 11 Apr 2013 21:18:32 +0100
Message-ID: <1365711512.7355.25.camel@bwh-desktop.uk.solarflarecom.com>
References: <a2c31e85628e006bdd6c621c0b14aeded4b62c66.1365684455.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	Richard Cochran <richardcochran@gmail.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:28045 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752598Ab3DKUSh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 16:18:37 -0400
In-Reply-To: <a2c31e85628e006bdd6c621c0b14aeded4b62c66.1365684455.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-04-11 at 14:48 +0200, Jiri Benc wrote:
> As network adapters supporting PTP are becoming more common, machines with
> many NICs suddenly have many PHCs, too. The current limit of eight /dev/ptp*
> char devices (and thus, 8 network interfaces with PHC) is insufficient. Let
> the ptp driver allocate the char devices dynamically.
> 
> idr is used for tracking minor numbers allocation; the mapping from index to
> pointer is not used, as it is not needed for posix clocks.

I think that means we should use IDA instead:
- Use ida_simple_get() instead of idr_alloc() (and drop the ptp
argument)
- Use ida_simple_remove() instead of idr_remove()
- Use ida_init() and ida_destroy()
- Don't bother with an external lock for the ida structure (the 'simple'
functions use a global spinlock, which should be fine for device
registration)

> Tested with 28 PHCs, removing and re-adding some of them.
> 
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
> ---
> v2: Removed dynamic allocation of chunks of minor numbers, the full minor
>     range is allocated instead.
> ---
>  drivers/ptp/ptp_clock.c |   60 +++++++++++++++++++++++++++++-----------------
>  1 files changed, 38 insertions(+), 22 deletions(-)
> 
> diff --git a/drivers/ptp/ptp_clock.c b/drivers/ptp/ptp_clock.c
> index 79f4bce..c8c57bc 100644
> --- a/drivers/ptp/ptp_clock.c
> +++ b/drivers/ptp/ptp_clock.c
[...]
> @@ -42,7 +41,7 @@
>  static dev_t ptp_devt;
>  static struct class *ptp_class;
>  
> -static DECLARE_BITMAP(ptp_clocks_map, PTP_MAX_CLOCKS);
> +static struct idr ptp_clocks_map;

As this is static, you can use DEFINE_IDR()/DEFINE_IDA() here and skip
calling idr_init()/ida_init().

[...]
> +       index = idr_alloc(&ptp_clocks_map, ptp, 0, 0, GFP_KERNEL);
> +       if (index < 0)
> +               goto no_idr;
> +       if (index > MINORMASK) {
> +               idr_remove(&ptp_clocks_map, index);
> +               index = -EBUSY;
> +       }
[...]

You should specify the end value (= MINORMASK + 1) to
idr_alloc()/ida_simple_get() rather than checking for it afterwards.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
