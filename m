From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH V5 9/9] hvsock: introduce Hyper-V VM Sockets feature
Date: Wed, 6 Jan 2016 05:27:17 +0000
Message-ID: <b50191f71b0f432593553cf23fab20ce@HKXPR3004MB0088.064d.mgd.msft.net>
References: <1450966503-13345-1-git-send-email-decui@microsoft.com>
 <87vb781hhq.fsf@vitty.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "pebolle@tiscali.nl" <pebolle@tiscali.nl>,
 "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "driverdev-devel@linuxdriverproject.org"
 <driverdev-devel@linuxdriverproject.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "stephen@networkplumber.org" <stephen@networkplumber.org>,
 "stefanha@redhat.com" <stefanha@redhat.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "apw@canonical.com" <apw@canonical.com>,
 "davem@davemloft.net" <davem@davemloft.net>,
 "dan.carpenter@oracle.com" <dan.carpenter@oracle.com>
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <87vb781hhq.fsf@vitty.brq.redhat.com>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

> From: Vitaly Kuznetsov [mailto:vkuznets@redhat.com]
> Sent: Tuesday, January 5, 2016 17:52
> 
> Just some minor nitpicks below -- I have to admit I didn't test the feature.
> 
> [..skip..]
> 
> > +
> > +	if (sk->sk_err) {
> > +		ret = -sk->sk_err;
> > +		goto out_wait_error;
> > +	} else {
> > +		ret = 0;
> > +	}
> > +
> > +out_wait:
> > +	finish_wait(sk_sleep(sk), &wait);
> > +out:
> > +	release_sock(sk);
> > +	return ret;
> > +
> > +out_wait_error:
> > +	sk->sk_state = SS_UNCONNECTED;
> > +	sock->state = SS_UNCONNECTED;
> > +	goto out_wait;
> > +}
> 
> Why not just place out_wait_error label before out_wait (and do 'goto
> out_wait' in ret = 0 case instead of 'goto out_wait_error' in the error
> case)?
Good point.  I'll update the code.

> [..skip..]
> 
> > +
> > +static int __init hvsock_init(void)
> > +{
> > +	int ret;
> > +
> > +	/* Hyper-V socket requires at least VMBus 4.0 */
> > +	if ((vmbus_proto_version >> 16) < 4) {
> > +		pr_err("failed to load: VMBus 4 or later is required\n");
> > +		return -ENODEV;
> 
> (Let me pretend I'm Dan :-) So here we return ...
> 
> > +	}
> > +
> > +	ret = vmbus_driver_register(&hvsock_drv);
> > +	if (ret) {
> > +		pr_err("failed to register hv_sock driver\n");
> > +		goto out;
> 
> ... and here we goto where we just return. I suggest we bring some
> consistency by directly returning ret here and eliminating 'out' label.

Thanks! I'll update the code.

> > +	}
> > +
> > +	ret = proto_register(&hvsock_proto, 0);
> > +	if (ret) {
> > +		pr_err("failed to register protocol\n");
> > +		goto unreg_hvsock_drv;
> > +	}
> > +
> > +	ret = sock_register(&hvsock_family_ops);
> > +	if (ret) {
> > +		pr_err("failed to register address family\n");
> > +		goto unreg_proto;
> > +	}
> > +
> > +	return 0;
> > +
> > +unreg_proto:
> > +	proto_unregister(&hvsock_proto);
> > +unreg_hvsock_drv:
> > +	vmbus_driver_unregister(&hvsock_drv);
> > +out:
> > +	return ret;
> > +}
> > +
> > +static void __exit hvsock_exit(void)
> > +{
> > +	sock_unregister(AF_HYPERV);
> > +	proto_unregister(&hvsock_proto);
> > +	vmbus_driver_unregister(&hvsock_drv);
> > +}
> > +
> > +module_init(hvsock_init);
> > +module_exit(hvsock_exit);
> > +
> > +MODULE_DESCRIPTION("Microsoft Hyper-V Virtual Socket Family");
> > +MODULE_VERSION("0.1");
> 
> Do we really need it? When the driver is commited we won't probably be
> updating it with v0.2 as a whole, we'll be sending patches addressing
> issues and there always will be a question when to swtich to 0.2, 0.3,
> ... And we don't have MODULE_VERSION for other Hyper-V drivers.

Good point. I'll remove the line MODULE_VERSION.
 
Thanks,
-- Dexuan
