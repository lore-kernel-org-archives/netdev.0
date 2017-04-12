From: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH rdma-next v1 04/12] IB/opa-vnic: Virtual Network
 Interface Controller (VNIC) netdev
Date: Wed, 12 Apr 2017 11:31:37 -0700
Message-ID: <20170412183136.GA19704@knc-06.sc.intel.com>
References: <1491979207-18686-1-git-send-email-niranjana.vishwanathapura@intel.com>
 <1491979207-18686-5-git-send-email-niranjana.vishwanathapura@intel.com>
 <20170412070830.GR2269@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Sadanand Warrier <sadanand.warrier-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Sudeep Dutt <sudeep.dutt-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Andrzej Kacprowski <andrzej.kacprowski-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170412070830.GR2269-U/DQcQFIOTAAJjI8aNfphQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 12, 2017 at 10:08:30AM +0300, Leon Romanovsky wrote:
>> +#define v_dbg(format, arg...) \
>> +	netdev_dbg(adapter->netdev, format, ## arg)
>> +#define v_err(format, arg...) \
>> +	netdev_err(adapter->netdev, format, ## arg)
>> +#define v_info(format, arg...) \
>> +	netdev_info(adapter->netdev, format, ## arg)
>> +#define v_warn(format, arg...) \
>> +	netdev_warn(adapter->netdev, format, ## arg)
>> +
>
>IMHO, these wrappers are redundant.
>

Using same constructs as some Intel standard ethernet drivers.

>> +/* opa_netdev_open - activate network interface */
>> +static int opa_netdev_open(struct net_device *netdev)
>> +{
>> +	struct opa_vnic_adapter *adapter = opa_vnic_priv(netdev);
>> +	int rc;
>> +
>> +	rc = adapter->rn_ops->ndo_open(adapter->netdev);
>> +	if (rc) {
>> +		v_dbg("open failed %d\n", rc);
>> +		return rc;
>> +	}
>> +
>> +	v_info("opened\n");
>
>All these v_info are achieved by tracepoints (function tracer).
>

Some of these messages are useful for analysing reported logs.
Let me change these opened/closed messges to debug level.

>> +
>> +	netdev = ibdev->alloc_rdma_netdev(ibdev, port_num,
>> +					  RDMA_NETDEV_OPA_VNIC,
>> +					  "veth%d", NET_NAME_UNKNOWN,
>> +					  ether_setup);
>> +	if (!netdev)
>> +		return ERR_PTR(-ENOMEM);
>> +	else if (IS_ERR(netdev))
>> +		return ERR_CAST(netdev);
>> +
>

>Erez and Jason came to this code for IPoIB, it is better to have same
>error handling for all alloc_rdma_netdev callers.
>+       if (hca->alloc_rdma_netdev) {
>+               dev = hca->alloc_rdma_netdev(hca, port,
>+                                            RDMA_NETDEV_IPOIB, name,
>+                                            NET_NAME_UNKNOWN,
>+                                            ipoib_setup_common);
>+               if (IS_ERR_OR_NULL(dev) && PTR_ERR(dev) != -EOPNOTSUPP)
>+                       return NULL;
>+       }
>
>

IPoIB handles EOPNOTSUPP differently (by assigning default operations).
It is not applicable to OPA VNIC, hence it just returns the error code.

I just noticed that IPoIB is using EOPNOTSUPP, however OPA VNIC is using 
ENOTSUPP. EOPNOTSUPP seesm to be widely used, so I will change OPA VNIC to use 
the same. Will also document this requirement in ib_verbs.h where this function 
is defined.

Niranjana

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
