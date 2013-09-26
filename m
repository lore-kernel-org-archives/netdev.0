From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH net v5 1/1] xen-netback: Handle backend state
 transitions in a more robust way
Date: Thu, 26 Sep 2013 11:17:22 +0100
Message-ID: <1380190642.29483.44.camel@kazak.uk.xensource.com>
References: <1380103168-12067-1-git-send-email-paul.durrant@citrix.com>
	 <1380103168-12067-2-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:22923 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755578Ab3IZKRY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Sep 2013 06:17:24 -0400
In-Reply-To: <1380103168-12067-2-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-09-25 at 10:59 +0100, Paul Durrant wrote:
> When the frontend state changes netback now specifies its desired state to
> a new function, set_backend_state(), which transitions through any
> necessary intermediate states.
> This fixes an issue observed with some old Windows frontend drivers where
> they failed to transition through the Closing state and netback would not
> behave correctly.

I'm somewhat terrified of breaking compatibility with some old or
obscure frontend here. I don't think it is reasonable to try and test
all of those so I guess we'll just have to deal with that when it
happens...

> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> Cc: Ian Campbell <ian.campbell@citrix.com>
> Cc: Wei Liu <wei.liu2@citrix.com>
> Cc: David Vrabel <david.vrabel@citrix.com>
> ---
>  drivers/net/xen-netback/xenbus.c |  143 ++++++++++++++++++++++++++++++--------
>  1 file changed, 113 insertions(+), 30 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
> index a53782e..01329b2 100644
> --- a/drivers/net/xen-netback/xenbus.c
> +++ b/drivers/net/xen-netback/xenbus.c
> @@ -24,6 +24,7 @@
>  struct backend_info {
>  	struct xenbus_device *dev;
>  	struct xenvif *vif;
> +	enum xenbus_state state;

This cannot just be read from xenstore because of the
wait-for-hotplug-script deferral stuff, right?

I'm not sure it is worth clarifying that, either by a comment or by
naming it deferred_state_change or something?

> -static void destroy_backend(struct xenbus_device *dev)
> +static void backend_connect(struct backend_info *be)
>  {
> -	struct backend_info *be = dev_get_drvdata(&dev->dev);
> +	if (be->vif)
> +		connect(be);
> +}
>  
> -	if (be->vif) {
> -		kobject_uevent(&dev->dev.kobj, KOBJ_OFFLINE);
> -		xenbus_rm(XBT_NIL, dev->nodename, "hotplug-status");
> -		xenvif_free(be->vif);
> -		be->vif = NULL;

Where did this uevent offlining functionality end up?

> +static inline void backend_switch_state(struct backend_info *be,
> +					enum xenbus_state state)
> +{
> +	struct xenbus_device *dev = be->dev;
> +
> +	pr_debug("%s -> %s\n", dev->nodename, xenbus_strstate(state));
> +	be->state = state;
> +
> +	/* If we are waiting for a hotplug script then defer the
> +	 * actual xenbus state change.

Is the right/wise regardless of the state we are moving too? Might the
state change have effectively "cancelled" the need to wait for the
script?

The previous code only deferred when moving to Connected. If we are now
moving to Closed/Closing do we still need to wait?


Ian.
