From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] Driver-core: Always create network class directories
 in get_device_parent.
Date: Mon, 21 Jun 2010 15:20:47 -0700
Message-ID: <20100621222047.GA27848@kroah.com>
References: <1276250151.3640.11.camel@jlt3.sipsolutions.net>
 <AANLkTil4IvOiDHnLwAaeseEPVgYp-EF5TK1HfHitY3-H@mail.gmail.com>
 <1276507247.3926.13.camel@jlt3.sipsolutions.net>
 <bug-16215-7251@https.bugzilla.kernel.org/>
 <AANLkTin2sci1gSmwx-tjazYGFAcUNRKhJFI7Bt0KvVe3@mail.gmail.com>
 <m139wiuswa.fsf_-_@fess.ebiederm.org>
 <AANLkTilVHF0dITpB3yJYaCnGPonhdl7NWnb-P12RAFTs@mail.gmail.com>
 <1277033628.3642.1.camel@jlt3.sipsolutions.net>
 <AANLkTikZAKZA9mfb7RjaqNFnX8gCM3A9PTfH350botL8@mail.gmail.com>
 <m1ocf5hnwh.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
	netdev <netdev@vger.kernel.org>,
	Kay Sievers <kay.sievers@vrfy.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:43892 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752504Ab0FUWUv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jun 2010 18:20:51 -0400
Content-Disposition: inline
In-Reply-To: <m1ocf5hnwh.fsf_-_@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 20, 2010 at 05:46:54AM -0700, Eric W. Biederman wrote:
> 
> In get_device_parent there was added check to not add a class
> directory when a class device was put under another class device.  The
> check was put in place as a just in case measure to not break old
> userspace if any existing code happened to depend on it.  Devices in
> the input subsystem are affected by this code path so there is a
> reasonable chance that some piece of user space will break if we just
> remove this kludge.
> 
> At the same time there are at least two network drivers that have
> potential unnecessary namespace conflicts because class directories
> have not been created for their network devices.
> 
> With the introduction of tagged sysfs directories for properly
> handling network namespace support this omission in creating the class
> directories went from a bad thing in terms of namespace pollution, to
> actually breaking device_remove.
> 
> Currently there are two reported network device drivers that break
> because the class directory was not created by the device layer.  The
> usb bnep driver and the mac80211_hwsim driver.
> 
> Every solution proposed changes the sysfs layout for the affected
> devices, and thus has the potential to break userspace.
> 
> Since we are changing the sysfs layout anyway, and since we are now
> talking about several devices all with the same problem, all caused by
> the same over convservative bit of code.  Let's fix the device layer
> for network devices.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
> ---
>  drivers/base/core.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/base/core.c b/drivers/base/core.c
> index 9630fbd..ffb8443 100644
> --- a/drivers/base/core.c
> +++ b/drivers/base/core.c
> @@ -673,7 +673,7 @@ static struct kobject *get_device_parent(struct device *dev,
>  		 */
>  		if (parent == NULL)
>  			parent_kobj = virtual_device_parent(dev);
> -		else if (parent->class)
> +		else if (parent->class && (strcmp(dev->class->name, "net") != 0))

No, we will not have subsystem specific hacks in the driver core like
this.  What would cause us to ever be able to delete this line?

thanks,

greg k-h
