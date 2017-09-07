From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH net-next v2 01/10] net: dsa: add debugfs interface
Date: Thu, 7 Sep 2017 21:34:34 +0200
Message-ID: <20170907193434.GA11006@kroah.com>
References: <20170828191748.19492-1-vivien.didelot@savoirfairelinux.com>
 <20170828191748.19492-2-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Egil Hjelmeland <privat@egil-hjelmeland.no>,
        John Crispin <john@phrozen.org>,
        Woojung Huh <Woojung.Huh@microchip.com>,
        Sean Wang <sean.wang@mediatek.com>,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>,
        Chris Healy <cphealy@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170828191748.19492-2-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I agree you shouldn't be using debugfs for this, but in the future, if
you do write debugfs code, please take the following review into
account:

On Mon, Aug 28, 2017 at 03:17:39PM -0400, Vivien Didelot wrote:
> +static int dsa_debugfs_create_port(struct dsa_switch *ds, int port)
> +{
> +	struct dentry *dir;
> +	char name[32];
> +
> +	snprintf(name, sizeof(name), DSA_PORT_FMT, port);
> +
> +	dir = debugfs_create_dir(name, ds->debugfs_dir);
> +	if (IS_ERR_OR_NULL(dir))
> +		return -EFAULT;

You should _never_ care about the return value of a debugfs call, and
you should not need to ever propagate the error upward.  The api was
written to not need this.

Just call the function, and return, that's it.  If you need to save the
return value (i.e. it's a dentry), you also don't care, just save it and
pass it to some other debugfs call, and all will still be fine.  Your
code should never do anything different if a debugfs call succeeds or
fails.

> +static int dsa_debugfs_create_switch(struct dsa_switch *ds)
> +{
> +	char name[32];
> +	int i, err;
> +
> +	/* skip if there is no debugfs support */
> +	if (!dsa_debugfs_dir)
> +		return 0;

Again, you don't care, all of these functions should return void.

> +	snprintf(name, sizeof(name), DSA_SWITCH_FMT, ds->index);
> +
> +	ds->debugfs_dir = debugfs_create_dir(name, dsa_debugfs_dir);
> +	if (IS_ERR_OR_NULL(ds->debugfs_dir))
> +		return -EFAULT;

See, that's horrid, you should never need to make such a bad check.

Also, even if it were the correct way to do this you never return EFAULT
unless there is a memory copy error to/from userspace.  That is not the
case here, or in any of this code, right?

> +static void dsa_debugfs_destroy_switch(struct dsa_switch *ds)
> +{
> +	/* handles NULL */
> +	debugfs_remove_recursive(ds->debugfs_dir);

Of course it handles NULL, why comment that?  That's the whole goal of
debugfs, to be dirt simple, allow you to do anything you want, in almost
no lines of code.

Also, it will never be mounted on a "real" system, so you better not
rely on it for anything "real".

> +		err = dsa_debugfs_create_switch(ds);
> +		if (err) {
> +			pr_warn("DSA: failed to create debugfs interface for switch %d (%d)\n",
> +				ds->index, err);

Never complain to the syslog about a debugfs issue.

> +void dsa_debugfs_destroy_module(void)
> +{
> +	/* handles NULL */
> +	debugfs_remove_recursive(dsa_debugfs_dir);

again, of course it does, do you think we don't know how to write an
api?  :)

thanks,

greg k-h
