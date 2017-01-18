From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC v2 00/10] HFI Virtual Network Interface Controller (VNIC)
Date: Wed, 18 Jan 2017 07:43:54 +0200
Message-ID: <20170118054354.GT32481@mtr-leonro.local>
References: <1481788782-89964-1-git-send-email-niranjana.vishwanathapura@intel.com>
 <20161215091226.GC811@mtr-leonro.local>
 <20161215145212.GA29116@phlsvsds.ph.intel.com>
 <380b05bf-a18e-1f20-7e8e-10b61f77dec7@redhat.com>
 <20161215170713.GD3264@obsidianresearch.com>
 <4e22bf29-2260-0768-ab17-9a8df6306f37@redhat.com>
 <20161215184837.GA16552@obsidianresearch.com>
 <20161216012404.GD3785@phlsvsds.ph.intel.com>
 <20161216041727.GA3797@obsidianresearch.com>
 <20170117192720.GA2833@knc-06.sc.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="BZziOT8Kz25R/m/E"
Cc: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
        "ira.weiny" <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170117192720.GA2833-wPcXA7LoDC+1XWohqUldA0EOCMrvLtNR@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--BZziOT8Kz25R/m/E
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Jan 17, 2017 at 11:27:20AM -0800, Vishwanathapura, Niranjana wrote:
> Thanks Jason for the valuable inputs.
>
> Here is the new generic interface.
>
> Overview:
> Bottom driver defines net_device_ops. The upper driver can override it.
> For example, upper driver can implement ndo_open() which calls bottom
> driver's ndo_open() and also do some book keeping.
>
>
> include/rdma/ib_verbs.h:
>
> /* rdma netdev type - specifies protocol type */
> enum rdma_netdev_t {
> 	RDMA_NETDEV_HFI_VNIC,
> };
>
> /* rdma netdev
>  * For usecases where netstack interfacing is required.
>  */
> struct rdma_netdev {
> 	struct net_device *netdev;
> 	u8 port_num;
>
> 	/* client private data structure */
> 	void *clnt_priv;
>
> 	/* control functions */
> 	void (*set_id)(struct rdma_netdev *rn, int id);
> 	void (*set_state)(struct rdma_netdev *rn, int state);
> };
>
> struct ib_device {
> 	...
> 	...
> 	/* rdma netdev operations */
> 	struct net_device *(*alloc_rdma_netdev)(struct ib_device *device,
> 					u8 port_num,
> 					enum rdma_netdev_t type,
> 					const char *name,
> 					unsigned char name_assign_type,
> 					void (*setup)(struct net_device *));
> 	void (*free_rdma_netdev)(struct net_device *netdev);
> };
>
>
> hfi1 driver:
>
> /* rdma netdev's private data structure */
> struct hfi1_rdma_netdev {
> 	struct rdma_netdev  rn;		/* keep this first */
> 	/* hfi1's vnic private data follows */
> };
>
>
> include/rdma/opa_hfi.h:
>
> /* Client's ndo operations use below function instead of netdev_priv() */
> static inline void *hfi_vnic_priv(const struct net_device *dev)
> {
> 	struct rdma_netdev *rn = netdev_priv(dev);
>
> 	return rn->clnt_priv;
> }
>
> /* Overrides rtnl_link_stats64 to include hfi_vnic stats.
>  * ndo_get_stats64() can be used to get the stats
>  */
> struct hfi_vnic_stats {
> 	/* standard netdev statistics */
> 	struct rtnl_link_stats64  netstat;
>
> 	/* HFI VNIC statistics */
> 	u64  tx_mcastbcast;
> 	u64  tx_untagged;
> 	u64  tx_vlan;
> 	u64  tx_64_size;
> 	u64  tx_65_127;
> 	u64  tx_128_255;
> 	u64  tx_256_511;
> 	u64  tx_512_1023;
> 	u64  tx_1024_1518;
> 	u64  tx_1519_max;
>
> 	u64  rx_untagged;
> 	u64  rx_vlan;
> 	u64  rx_64_size;
> 	u64  rx_65_127;
> 	u64  rx_128_255;
> 	u64  rx_256_511;
> 	u64  rx_512_1023;
> 	u64  rx_1024_1518;
> 	u64  rx_1519_max;
>
> 	u64  rx_runt;
> 	u64  rx_oversize;
> };
>
> I have started working on porting hfi_vnic as per this new interface.
> I will post RFC v3 later.
> Posting the interface definition early for comments.

I wonder how many people will comment it without seeing usage example.

>
> Thanks,
> Niranjana
>

--BZziOT8Kz25R/m/E
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlh/AJkACgkQ5GN7iDZy
WKeL1Q//c9DeXX7s+UTUC5prdCRu+VF2JrqJeGxgicNSt4MLC8H42F8F7fWjijWH
1tkdbChZ8rnqhoADfOMKP45ZMFX94lv89juc5UKqMSlPQ6obR6oV+PUE6+4rjK5n
pY2IYg9TbckaU0GROPkSwke4xNAtUD2rakhHZXWj0y2RP6yxIKLjZfZbDntFYE/8
gvqTKHvw6JatBw23v/uA0kJJ0GRYYvuIdCGsjB0DBiWZQJG0l9utwhR3GREuapIK
Gfm46CknYDDaCLhgw5uZJLhIoDtELdt+fjCfKzU6ln/RcfSS+R8td2Vojd59VvcX
+OW+2Eg44HpdoKUnG00rrUJSblF+b0AinYwR6aW8Cn4J0XPLoAitmOQLPEDRsnEm
/ZfQAKLBi8nBwqyeD6ipfWbr5N/u3JXrnyaMxe56+sFvu/Qjmpae5t+CsyaOUTwe
YJURxNASjnrnNDtSL4EaMycX9H6ricVkVFtYkmtJ07yKMG3t+Xht7VSaRIRyQyUc
Ela7fv1WLowku2J78d9Lc1oHZe3j4doLHFM7PYcxern1+z1sUZ8w9Chf/lr8ommh
ppV4WqcriliNaDveYLbHfacdIH3prqHjLGNPe6XkS+04/Am5gxDOtlfTsjuZUCjr
YIQRAQNcz1i/foLLaffWEPbWefSsHDFmPGzbeULNhRiACSI5hw4=
=CwKG
-----END PGP SIGNATURE-----

--BZziOT8Kz25R/m/E--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
