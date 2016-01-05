From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [PATCH V5 9/9] hvsock: introduce Hyper-V VM Sockets feature
Date: Tue, 05 Jan 2016 10:51:45 +0100
Message-ID: <87vb781hhq.fsf@vitty.brq.redhat.com>
References: <1450966503-13345-1-git-send-email-decui@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: gregkh@linuxfoundation.org, davem@davemloft.net,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	driverdev-devel@linuxdriverproject.org, olaf@aepfle.de,
	apw@canonical.com, jasowang@redhat.com, kys@microsoft.com,
	pebolle@tiscali.nl, stefanha@redhat.com, dan.carpenter@oracle.com
To: Dexuan Cui <decui@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1450966503-13345-1-git-send-email-decui@microsoft.com> (Dexuan
	Cui's message of "Thu, 24 Dec 2015 06:15:03 -0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dexuan Cui <decui@microsoft.com> writes:

Just some minor nitpicks below -- I have to admit I didn't test the feature.

[..skip..] 

> +
> +	if (sk->sk_err) {
> +		ret = -sk->sk_err;
> +		goto out_wait_error;
> +	} else {
> +		ret = 0;
> +	}
> +
> +out_wait:
> +	finish_wait(sk_sleep(sk), &wait);
> +out:
> +	release_sock(sk);
> +	return ret;
> +
> +out_wait_error:
> +	sk->sk_state = SS_UNCONNECTED;
> +	sock->state = SS_UNCONNECTED;
> +	goto out_wait;
> +}

Why not just place out_wait_error label before out_wait (and do 'goto
out_wait' in ret = 0 case instead of 'goto out_wait_error' in the error
case)?

[..skip..]

> +
> +static int __init hvsock_init(void)
> +{
> +	int ret;
> +
> +	/* Hyper-V socket requires at least VMBus 4.0 */
> +	if ((vmbus_proto_version >> 16) < 4) {
> +		pr_err("failed to load: VMBus 4 or later is required\n");
> +		return -ENODEV;

(Let me pretend I'm Dan :-) So here we return ...

> +	}
> +
> +	ret = vmbus_driver_register(&hvsock_drv);
> +	if (ret) {
> +		pr_err("failed to register hv_sock driver\n");
> +		goto out;

... and here we goto where we just return. I suggest we bring some
consistency by directly returning ret here and eliminating 'out' label. 

> +	}
> +
> +	ret = proto_register(&hvsock_proto, 0);
> +	if (ret) {
> +		pr_err("failed to register protocol\n");
> +		goto unreg_hvsock_drv;
> +	}
> +
> +	ret = sock_register(&hvsock_family_ops);
> +	if (ret) {
> +		pr_err("failed to register address family\n");
> +		goto unreg_proto;
> +	}
> +
> +	return 0;
> +
> +unreg_proto:
> +	proto_unregister(&hvsock_proto);
> +unreg_hvsock_drv:
> +	vmbus_driver_unregister(&hvsock_drv);
> +out:
> +	return ret;
> +}
> +
> +static void __exit hvsock_exit(void)
> +{
> +	sock_unregister(AF_HYPERV);
> +	proto_unregister(&hvsock_proto);
> +	vmbus_driver_unregister(&hvsock_drv);
> +}
> +
> +module_init(hvsock_init);
> +module_exit(hvsock_exit);
> +
> +MODULE_DESCRIPTION("Microsoft Hyper-V Virtual Socket Family");
> +MODULE_VERSION("0.1");

Do we really need it? When the driver is commited we won't probably be
updating it with v0.2 as a whole, we'll be sending patches addressing
issues and there always will be a question when to swtich to 0.2, 0.3,
... And we don't have MODULE_VERSION for other Hyper-V drivers.

> +MODULE_LICENSE("Dual BSD/GPL");

-- 
  Vitaly
