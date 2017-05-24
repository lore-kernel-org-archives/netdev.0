From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH net-next 2/4] nfp: register ports as devlink ports
Date: Wed, 24 May 2017 12:24:13 -0700
Message-ID: <20170524122413.702e0eef@cakuba.netronome.com>
References: <20170523151247.8535-1-jakub.kicinski@netronome.com>
        <20170523151247.8535-3-jakub.kicinski@netronome.com>
        <20170524123514.GB1908@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.10]:43430 "EHLO mx3.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S937319AbdEXTYg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 24 May 2017 15:24:36 -0400
In-Reply-To: <20170524123514.GB1908@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 24 May 2017 14:35:14 +0200, Jiri Pirko wrote:
> >+void nfp_devlink_port_unregister(struct nfp_port *port)
> >+{
> >+	/* Due to unpleasant lock ordering we may see the port go away before
> >+	 * we have fully probed.  
> 
> Could you elaborate on this a bit more please?

It's partially due to peculiarities of the management FW more than
kernel stuff.  Unfortunately some ethtool media config requires reboot
to be applied, so we print a friendly message to the logs and
unregister the associated netdevs.  Which means once netdevs get
registered ports may go away.

Enter devlink, I need the ability to grab the adapater lock in
split/unsplit callbacks to find the ports, which implies having to drop
that lock before I register devlink.  And only after I register devlink
can I register the ports.

I could do init without registering anything, drop the adapter lock,
register devlink, and then grab the adapter lock back and register
devlink ports and netdevs.  But there is another issue...

Since I look for ports on a list maintained in the adapter struct,
driver code doesn't care if devlink_port has been registered or not.
The moment devlink is registered, split/unsplit requests will be
accepted - potentially trying to unregister devlink_port before the
register could happen.

Further down the line, also, the eswitch mode setting is coming.  Which
means the moment I register devlink itself ports will get shuffled (due
to the plan of registering VFs as ports :)). 

I feel like registering devlink should be the last action of the
driver, really.  My plan was to keep that simple if() for now, and once
we get to extending devlink with SR-IOV stuff also add the ability to
pre-register ports.  Allow registering ports on not-yet-registered
devlink (probably put them on a private list within struct devlink).
This would make devlink_register() a single point when everything
devlink becomes visible, atomically, instead of devlink itself coming
first and then ports following.

Does that make sense?  Am I misreading the code (again :S)?
