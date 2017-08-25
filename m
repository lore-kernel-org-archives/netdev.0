From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH v2 net-next 1/1] hv_sock: implements Hyper-V transport for
 Virtual Sockets (AF_VSOCK)
Date: Fri, 25 Aug 2017 03:19:22 +0000
Message-ID: <KL1P15301MB0008DD63FB6D476484DFF5BFBF9B0@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
References: <KL1P15301MB0008D0FB2F8F5B90E7737C3CBF850@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
 <20170824.181931.584865895464286033.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "jhansen@vmware.com" <jhansen@vmware.com>,
        "stefanha@redhat.com" <stefanha@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "mkubecek@suse.cz" <mkubecek@suse.cz>,
        "joe@perches.com" <joe@perches.com>,
        "olaf@aepfle.de" <olaf@aepfle.de>,
        Stephen Hemminger <sthemmin@microsoft.com>,
        "jasowang@redhat.com" <jasowang@redhat.com>,
        "KY Srinivasan" <kys@microsoft.com>,
        Haiyang Zhang <haiyangz@microsoft.com>,
        "dave.scott@docker.com" <dave.scott@docker.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "apw@canonical.com" <apw@canonical.com>,
        "rolf.neugebauer@docker.com" <rolf.neugebauer@docker.com>,
        "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
        "marcelo.cerri@canonical.com" <marcelo.cerri@canonical.com>,
        "devel@linuxdriverpr
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170824.181931.584865895464286033.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: David Miller [mailto:davem@davemloft.net]
> Sent: Thursday, August 24, 2017 18:20
> > +#define VMBUS_PKT_TRAILER  (sizeof(u64))
>
> This is not the packet trailer, it's the size of the packet trailer.

Thanks! I'll change it to VMBUS_PKT_TRAILER_SIZE.

> > +   /* Have we sent the zero-length packet (FIN)? */
> > +   unsigned long fin_sent;
>
> Why does this need to be atomic?  Why can't a smaller simpler
It doesn't have to be. It was originally made for a quick workaround.
Thanks! I should do it in the right way now.

> mechanism be used to make sure hvs_shutdown() only performs
> hvs_send_data() call once on the channel?
I'll change "fin_sent" to bool, and avoid test_and_set_bit().
I'll add lock_sock/release_sock()  in hvs_shutdown() like this:

static int hvs_shutdown(struct vsock_sock *vsk, int mode)
{
 ...
       lock_sock(sk);

        hvs =3D vsk->trans;
        if (hvs->fin_sent)
                goto out;

        send_buf =3D (struct hvs_send_buf *)&hdr;
        (void)hvs_send_data(hvs->chan, send_buf, 0);

        hvs->fin_sent =3D true;
out:
        release_sock(sk);
        return 0;
}

> > +static inline bool is_valid_srv_id(const uuid_le *id)
> > +{
> > +   return !memcmp(&id->b[4], &srv_id_template.b[4], sizeof(uuid_le) -
> 4);
> > +}
>
> Do not use the inline function attribute in *.c code.  Let the
> compiler decide.

OK. Will remove all the inline usages.

> > +   *((u32 *)&h->vm_srv_id) =3D vsk->local_addr.svm_port;
> > +   *((u32 *)&h->host_srv_id) =3D vsk->remote_addr.svm_port;
>
> There has to be a better way to express this.
I may need to define a uinon here. Let me try it.

 > And if this is partially initializing vm_srv_id, at a minimum
> endianness needs to be taken into account.
I may need to use cpu_to_le32(). Let me check it.
