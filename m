From: Christopher Li <sparse@chrisli.org>
Subject: Re: fec_main: context imbalance in 'fec_set_features'
Date: Sat, 11 Oct 2014 10:07:13 +0800
Message-ID: <CANeU7Qn2WX3CCN5YzFqcWngYu_Uy2wQ=mW1gBhGYMAaLhOkkZg@mail.gmail.com>
References: <CAOMZO5CJKp7+d8EPRZdr-3Bd9UxVU8fxLybFZ4uLn+cUQjPH8w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Frank Li <Frank.Li@freescale.com>,
	Duan Fugang-B38611 <B38611@freescale.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux-Sparse <linux-sparse@vger.kernel.org>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <linux-sparse-owner@vger.kernel.org>
In-Reply-To: <CAOMZO5CJKp7+d8EPRZdr-3Bd9UxVU8fxLybFZ4uLn+cUQjPH8w@mail.gmail.com>
Sender: linux-sparse-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 2, 2014 at 8:15 AM, Fabio Estevam <festevam@gmail.com> wrote:
> Hi,
>
> sparse complains the following:
>
> drivers/net/ethernet/freescale/fec_main.c:2835:12: warning: context
> imbalance in 'fec_set_features' - different lock contexts for basic
> block

That is expected to receive warnings. Sparse can't really tell the lock
and unlock are actually on the same condition and it never change.

>
> The code looks like this:
>
> static int fec_set_features(struct net_device *netdev,
>     netdev_features_t features)
> {
>     struct fec_enet_private *fep = netdev_priv(netdev);
>     netdev_features_t changed = features ^ netdev->features;
>
>     /* Quiesce the device if necessary */
>     if (netif_running(netdev) && changed & FEATURES_NEED_QUIESCE) {

e.g. netdev is running here, you take the lock.


>         napi_disable(&fep->napi);
>         netif_tx_lock_bh(netdev);
>         fec_stop(netdev);
>     }
>
>     netdev->features = features;
>>
>     /* Resume the device after updates */
>     if (netif_running(netdev) && changed & FEATURES_NEED_QUIESCE) {

Then there is race some one shutdown the netdev before the code hits
here (is it possible? it is hard to tell from this source alone.)
Then the unlock is skipped.

>         fec_restart(netdev);
>         netif_tx_wake_all_queues(netdev);

Sparse is complaining, there exist a code path, from execution flow
point of view, (without considering the data flow analyze), there exists a
code path lock and unlock are not balanced.

It is possible that warning code path is not actually executable
due to data flow reason(e.g. "changed" never change during the same function).
But sparse did not have data flow analyze to know that.

If you move the code, e.g. the code inside the lock area into a function.
You can write:

if (need_lock) {
       lock();
       do_something_real();
       unlock();
} else {
       do_something_real();
}

That way, sparse don't see such a code path can trigger lock unbalanced.

Chris
