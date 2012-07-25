From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 03/17] Drivers: hv: kvp: Cleanup error handling in KVP
Date: Wed, 25 Jul 2012 15:47:25 +0100
Message-ID: <20120725144724.GD1894@decadent.org.uk>
References: <1343145672-3641-1-git-send-email-kys@microsoft.com>
 <1343145701-3691-1-git-send-email-kys@microsoft.com>
 <1343145701-3691-3-git-send-email-kys@microsoft.com>
 <1343178644.5132.103.camel@deadeye.wl.decadent.org.uk>
 <426367E2313C2449837CD2DE46E7EAF9236A8B61@SN2PRD0310MB382.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	"virtualization@lists.osdl.org" <virtualization@lists.osdl.org>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"apw@canonical.com" <apw@canonical.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: KY Srinivasan <kys@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <426367E2313C2449837CD2DE46E7EAF9236A8B61@SN2PRD0310MB382.namprd03.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 25, 2012 at 02:10:05PM +0000, KY Srinivasan wrote:
> 
> 
> > -----Original Message-----
> > From: Ben Hutchings [mailto:ben@decadent.org.uk]
> > Sent: Tuesday, July 24, 2012 9:11 PM
> > To: KY Srinivasan
> > Cc: gregkh@linuxfoundation.org; linux-kernel@vger.kernel.org;
> > devel@linuxdriverproject.org; virtualization@lists.osdl.org; olaf@aepfle.de;
> > apw@canonical.com; netdev@vger.kernel.org
> > Subject: Re: [PATCH 03/17] Drivers: hv: kvp: Cleanup error handling in KVP
> > 
> > On Tue, 2012-07-24 at 09:01 -0700, K. Y. Srinivasan wrote:
> > > In preparation to implementing IP injection, cleanup the way we propagate
> > > and handle errors both in the driver as well as in the user level daemon.
> > >
> > > Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
> > > Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>
> > > ---
> > >  drivers/hv/hv_kvp.c      |  112 +++++++++++++++++++++++++++++++++++++-
> > --------
> > >  include/linux/hyperv.h   |   17 +++++---
> > >  tools/hv/hv_kvp_daemon.c |   70 +++++++++++++++-------------
> > >  3 files changed, 138 insertions(+), 61 deletions(-)
> > >
> > > diff --git a/drivers/hv/hv_kvp.c b/drivers/hv/hv_kvp.c
> > > index 0012eed..9b7fc4a 100644
> > > --- a/drivers/hv/hv_kvp.c
> > > +++ b/drivers/hv/hv_kvp.c
> > [...]
> > > @@ -109,27 +154,52 @@ kvp_cn_callback(struct cn_msg *msg, struct
> > netlink_skb_parms *nsp)
> > >  {
> > >  	struct hv_kvp_msg *message;
> > >  	struct hv_kvp_msg_enumerate *data;
> > > +	int	error = 0;
> > >
> > >  	message = (struct hv_kvp_msg *)msg->data;
> > > -	switch (message->kvp_hdr.operation) {
> > > +
> > > +	/*
> > > +	 * If we are negotiating the version information
> > > +	 * with the daemon; handle that first.
> > > +	 */
> > > +
> > > +	if (in_hand_shake) {
> > > +		if (kvp_handle_handshake(message))
> > > +			in_hand_shake = false;
> > > +		return;
> > > +	}
> > > +
> > > +	/*
> > > +	 * Based on the version of the daemon, we propagate errors from the
> > > +	 * daemon differently.
> > > +	 */
> > > +
> > > +	data = &message->body.kvp_enum_data;
> > > +
> > > +	switch (dm_reg_value) {
> > >  	case KVP_OP_REGISTER:
> > > -		pr_info("KVP: user-mode registering done.\n");
> > > -		kvp_register();
> > > -		kvp_transaction.active = false;
> > > -		hv_kvp_onchannelcallback(kvp_transaction.kvp_context);
> > > +		/*
> > > +		 * Null string is used to pass back error condition.
> > > +		 */
> > > +		if (!strlen(data->data.key))
> > 
> > Do we know that the key is null-terminated here?  Shouldn't we just
> > check whether data->data.key[0] == 0?
> 
> Yes, currently we do return null string to indicate error.
[...]

So the kernel should assume userland input is always valid?

Ben.

-- 
Ben Hutchings
We get into the habit of living before acquiring the habit of thinking.
                                                              - Albert Camus
