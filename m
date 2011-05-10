From: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Subject: Re: Fw: oops during unregister_netdevice interface enslaved to
	bond - regression
Date: Tue, 10 May 2011 16:20:47 +0200
Message-ID: <20110510142047.GB39624@tuxmaker.boeblingen.de.ibm.com>
References: <OF0F4919C3.B9CFCAE8-ONC125788C.002D5EB1-C125788C.002D83B7@de.ibm.com> <1305017672.2614.9.camel@edumazet-laptop> <20110510131438.GA41522@tuxmaker.boeblingen.de.ibm.com> <1305034619.2614.37.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org, ELELUECK@de.ibm.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.uk.ibm.com ([194.196.100.166]:51627 "EHLO
	mtagate6.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932550Ab1EJOUu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 10:20:50 -0400
Content-Disposition: inline
In-Reply-To: <1305034619.2614.37.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 10, 2011 at 03:36:59PM +0200, Eric Dumazet wrote:
> Le mardi 10 mai 2011 =E0 15:14 +0200, Frank Blaschka a =E9crit :
>=20
> > I just checked todays net-next tree, problem is still there.
> > I don't have an x86 box, but I was able to reproduce the problem
> > with the dummy device (on s/390)
> >=20
> > # modprobe bonding
> > # modprobe dummy
> > # ifconfig bond0 up
> > # ifenslave bond0 dummy0
> > # rmmod dummy
>=20
> Here is the patch to fix this problem
>
Hi Eric,

your patch did the trick. With the patch applied I could not
reproduce the problem anyhow I use real or dummy device.

Thx for your help!
=20
> Thanks again for your help.
>=20
> [PATCH net-2.6] net: dev_close() should check IFF_UP
>=20
> Commit 443457242beb (factorize sync-rcu call in
> unregister_netdevice_many) mistakenly removed one test from dev_close=
()
>=20
> Following actions trigger a BUG :
>=20
> modprobe bonding
> modprobe dummy
> ifconfig bond0 up
> ifenslave bond0 dummy0
> rmmod dummy
>=20
> dev_close() must not close a non IFF_UP device.
>=20
> With help from Frank Blaschka and Einar EL Lueck
>=20
> Reported-by: Frank Blaschka <blaschka@linux.vnet.ibm.com>
> Reported-by: Einar EL Lueck <ELELUECK@de.ibm.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Octavian Purdila <opurdila@ixiacom.com>
> ---
>  net/core/dev.c |   10 ++++++----
>  1 file changed, 6 insertions(+), 4 deletions(-)
>=20
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 856b6ee..9200944 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1284,11 +1284,13 @@ static int dev_close_many(struct list_head *h=
ead)
>   */
>  int dev_close(struct net_device *dev)
>  {
> -	LIST_HEAD(single);
> +	if (dev->flags & IFF_UP) {
> +		LIST_HEAD(single);
>=20
> -	list_add(&dev->unreg_list, &single);
> -	dev_close_many(&single);
> -	list_del(&single);
> +		list_add(&dev->unreg_list, &single);
> +		dev_close_many(&single);
> +		list_del(&single);
> +	}
>  	return 0;
>  }
>  EXPORT_SYMBOL(dev_close);
>=20
>=20
