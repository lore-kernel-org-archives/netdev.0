From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next V1 00/11] Mellanox 100G extending mlx5 ethtool support
Date: Tue, 26 Apr 2016 23:55:03 +0300
Message-ID: <CALzJLG-BJvB7h2wAOqy8ibDdkw7Croaiy7+QU9izrcivuS1yOg@mail.gmail.com>
References: <1461527516-29290-1-git-send-email-saeedm@mellanox.com> <20160426.160301.938979848864279754.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f196.google.com ([209.85.161.196]:32871 "EHLO
	mail-yw0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752355AbcDZUzX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 16:55:23 -0400
Received: by mail-yw0-f196.google.com with SMTP id o63so4911776ywe.0
        for <netdev@vger.kernel.org>; Tue, 26 Apr 2016 13:55:23 -0700 (PDT)
In-Reply-To: <20160426.160301.938979848864279754.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 26, 2016 at 11:03 PM, David Miller <davem@davemloft.net> wrote:
>
> Series applied.
>
> Be careful about what feature update semantics you implement.  If you get a request
> to change multiple feature bits, and even one of them cannot be done, the entire
> update operation should fail and the bits should revert to what they were before
> the request.

It will be a nightmare to rollback in such case.  What if the rollback failed ?

>
> Is that how the code behaves now?
>

Not exactly.  If the set/clear of Bit(I) is performed successfully we
set/clear that feature in dev->features ourselves,
and if one fails we return a negative error code so
__netdev_update_features will notify on the failure, but we will be
left with the features that we did success to modify.

__netdev_update_features@net/core/dev.c

if (unlikely(err < 0)) {
        netdev_err(dev,
                        "set_features() failed (%d); wanted %pNF, left %pNF\n",
                        err, &features, &dev->features);
        /* return non-0 since some features might have changed and
         * it's better to fire a spurious notification than miss it
         */
         return -1;
}

>From this I understand it is ok to update the dev->features inside the
device's set_features NDO and return a negative value in case of
failure,
and a notification on changed features will be fired in anycase.

Is this a correct assumption ?

Anyhow if you think this behavior should be fixed, we will fix it.
Failures at set_features should be rare and should be debugged rather
than ignored.

Saeed.
