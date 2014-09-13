From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 net-next 1/3] sunvnet: upgrade to VIO protocol
 version 1.6
Date: Sat, 13 Sep 2014 16:18:42 -0400 (EDT)
Message-ID: <20140913.161842.2265200935397549583.davem@davemloft.net>
References: <54146A42.1050703@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: david.stevens@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37798 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752134AbaIMUSo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Sep 2014 16:18:44 -0400
In-Reply-To: <54146A42.1050703@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David L Stevens <david.stevens@oracle.com>
Date: Sat, 13 Sep 2014 12:01:06 -0400

> @@ -368,6 +381,8 @@ struct vio_driver_state {
>  	char			*name;
>  
>  	struct vio_driver_ops	*ops;
> +
> +	u64			rmtu;	/* remote MTU */
>  };
>  
>  #define viodbg(TYPE, f, a...) \

Is this really applicable to devices other than sunvnet?  Just keep
this attribute in the sunvnet driver "struct vnet_port" private state.

> +	/* v1.6 and higher, ACK with desired, supported mode, or NACK */
> +	if (vio->ver.major <= 1 && vio->ver.minor >= 6) {
 ...
> +	if (vio->ver.major <= 1 && vio->ver.minor < 2)
 ...
> +	/* for version < 1.2, VIO_DRING_MODE = 0x3 and no bitmask */
> +	if ((vio->ver.major <= 1 &&  vio->ver.minor < 2) &&
...
> +	if (vio->ver.major == 1 && vio->ver.minor < 3) {
	...
> +	} else if (vio->ver.major == 1 && vio->ver.minor == 3) {
	...
> +	} else {
	...
> +	}
 ...
> +	/* for version >= 1.6, ACK packet mode we support */
> +	if (vio->ver.major <= 1 && vio->ver.minor >= 6) {

These version tests give me a headache, and some of them accept
impossible things like major version zero.  If we only have major
version 1 and later in our version lists, testing things like "major
<= 1" makes no sense at all.

That last test quoted above definitely looks wrong, it should
be testing "major >= 1" if anything if it is trying to test
"version >= 1.6"

Sadly, I expect that we'll have more and more of these version tests
over time.  So why not make some generic helpers in the VIO or LDC
layer?

static inline bool vio_version_before(struct vio_driver_state *vio,
				      u16 major, u16 minor)
{
	u32 have = (u32)vio->major << 16 | vio->minor;
	u32 want = (u32)major << 16 | minor;

	return have < want;
}
static inline bool vio_version_after_eq(struct vio_driver_state *vio,
					u16 major, u16 minor)
{
	u32 have = (u32)vio->major << 16 | vio->minor;
	u32 want = (u32)major << 16 | minor;

	return have >= want;
}

Something like that.
