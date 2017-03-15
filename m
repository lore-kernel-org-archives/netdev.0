From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [RFC v1 for accelerated IPoIB 05/25] IB/ipoib: Support ipoib
 acceleration options callbacks
Date: Wed, 15 Mar 2017 19:39:06 +0200
Message-ID: <20170315173906.GF2079@mtr-leonro.local>
References: <1489429896-10781-1-git-send-email-erezsh@mellanox.com>
 <1489429896-10781-6-git-send-email-erezsh@mellanox.com>
 <20170314063538.GB79937@knc-06.sc.intel.com>
 <CAAk-MO8gQ5x-4Ubk1nzPntEWa2ivTK6uXyJ4eC7fmtUCNnOdfA@mail.gmail.com>
 <20170314160021.GD3244@obsidianresearch.com>
 <20170315064751.GD2079@mtr-leonro.local>
 <20170315155802.GB29562@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="iBHcHRCIarfY7C0j"
Cc: Erez Shitrit <erezsh-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>,
        "Vishwanathapura, Niranjana" <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <valex-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        <saedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170315155802.GB29562-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--iBHcHRCIarfY7C0j
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Mar 15, 2017 at 09:58:02AM -0600, Jason Gunthorpe wrote:
> On Wed, Mar 15, 2017 at 08:47:51AM +0200, Leon Romanovsky wrote:
> > On Tue, Mar 14, 2017 at 10:00:21AM -0600, Jason Gunthorpe wrote:
> > > On Tue, Mar 14, 2017 at 04:42:55PM +0200, Erez Shitrit wrote:
> > > > >> +       if (!hca->alloc_rdma_netdev)
> > > > >> +               dev = ipoib_create_netdev_default(hca, name,
> > > > >> ipoib_setup_common);
> > > > >> +       else
> > > > >> +               dev = hca->alloc_rdma_netdev(hca, port, RDMA_NETDEV_IPOIB,
> > > > >> +                                            name, NET_NAME_UNKNOWN,
> > > > >> +                                            ipoib_setup_common);
> > > > >> +       if (!dev) {
> > > > >> +               kfree(priv);
> > > > >> +               return NULL;
> > > > >> +       }
> > > > >
> > > > >
> > > > > This will break ipoib on hfi1 as hfi1 will define alloc_rdma_netdev for
> > > > > OPA_VNIC type. We should probably look for a dedicated return type
> > > > > (-ENODEV?) to determine of the driver supports specified rdma netdev type.
> > > > > Or use a ib device attribute to suggest driver support ipoib rdma netdev.
> > > >
> > > > sorry, I don't understand that, we are in ipoib driver, so the type is
> > > > RDMA_NETDEV_IPOIB, if hfi wants to implement it should use the same
> > > > flag, and to use OPA_VNIC for vnic.
> > >
> > > He means it should look like this:
> > >
> > >  if (hca->alloc_rdma_netdev)
> > >      dev = hca->alloc_rdma_netdev(hca, port, RDMA_NETDEV_IPOIB,
> > >                                             name, NET_NAME_UNKNOWN,
> > >                                             ipoib_setup_common);
> > >
> > >  if (IS_ERR(dev) && PTR_ERR(dev) != ENOTSUP)
> > >       goto out;
> > >
> > >  dev = ipoib_create_netdev_default(hca, name, ipoib_setup_common);
> > >  if (IS_ERR(dev))
> > >       goto out;
> > >
> > >  WARN_ON(dev == NULL);
> > >
> > >   [...]
> > >
> > > out:
> > >       return PTR_ERR(dev);
> > >
> > > And I'm confused why 'ipoib_create_netdev_default' doesn't need the
> > > same function signature as hca->alloc_rdma_netdev
> >
> > And now, I'm confused.
> > In your's proposal, the "dev" will be overwritten, in Erez's proposal,
> > "dev" will be one of two: defaults or device specific.
>
> Well, not Erez's version allowed dev to be ERR_PTR too. More like this then
>
> struct rdma_netdev *get_netdev(..)
> {
>    if (hca-alloc_rdma_netdev) {
>        dev = hca-alloc_rdma_netdev(hca, port, RDMA_NETDEV_IPOIB,
>                                               name, NET_NAME_UNKNOWN,
>                                               ipoib_setup_common);
>
>        if (!IS_ERR(dev) || PTR_ERR(dev) != ENOTSUP)
>            return dev;
>    }
>
>    return ipoib_create_netdev_default(hca, name, ipoib_setup_common);
> }

Thanks, I agree with you, the interfaces should properly handle errors
paths from day one.

>
> Jason
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--iBHcHRCIarfY7C0j
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAljJfDoACgkQ5GN7iDZy
WKeXow//aKHd6faANpjuoWSewqU+fVd0W4oal5JNVmOi/aD2xV43VIHTdY6mE41I
vqOh/f1ZT9fV5fL6Km79zWOlBABBuHCv7kPZiMG/1h0v7QAJKdLHe3S2tvDzcA8f
yVttFIYUIeGCXYm738xYXikBAu5l7w+cS0tJ4yYpe/Id7BdFepJdqDhrFoM220xe
JBXIbQdeoITPoqZw4N4PTStU6fmrqzfJM4ChVLA28oE43GP03+zKTHZNk5sjtykn
j1m8jLzgjb2NP/OxOJvjystHzJeqqC/jymbWTgVPc+1+ASXSzpdJ46XNQkWGxfjp
ALcowPoRoN0TKnJzk/BZrtkr0icTu5EerfiA9YINo+mZHADw7AtaprXowcaw3Di4
VkVAegJFujUWOdmK7ivvGl45jJcrjRIYj1JMZtluQ+47iNGOCKkGZp+oeiTUIn0k
tpRldxAi+fxU2BFmWaJEVdrw9bYXA3OFuQQKNLrLXTo9WFmc9TRBa2Z8MTwr7fQC
nwbqYIRkmxy5tsFN+u/fyqk+OSGgexVIDEIK/RKngwj5rhvyMMzpl3KqcRaC45MP
8EextO2r/IN1xl6ThugfV2a7dHk3DOaDdG/7BShZ5j2Jkoe8AFdmijW1t0/AjQX6
ltyxyiUaiCwhe5Jhmie2xkOerJIwdXb+V8nnGFpbvWagly5pagk=
=/O5E
-----END PGP SIGNATURE-----

--iBHcHRCIarfY7C0j--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
