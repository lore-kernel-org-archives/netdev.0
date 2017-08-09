From: "Yang, Yi Y" <yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next] openvswitch: add NSH support
Date: Wed, 9 Aug 2017 09:41:51 +0000
Message-ID: <79BBBFE6CB6C9B488C1A45ACD284F51961C3ADBE@SHSMSX103.ccr.corp.intel.com>
References: <1502168380-106785-1-git-send-email-yi.y.yang@intel.com>
	<20170808162810.1bab3812@griffin>
	<79BBBFE6CB6C9B488C1A45ACD284F51961C391CA@SHSMSX103.ccr.corp.intel.com>
	<20170809024200.GG6175@ovn.org>
	<CFF8EF42F1132E4CBE2BF0AB6C21C58D72735682@ESESSMB107.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Jan Scheurich <jan.scheurich-IzeFyvvaP7pWk0Htik3J/w@public.gmane.org>, Ben Pfaff <blp-LZ6Gd1LRuIk@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <CFF8EF42F1132E4CBE2BF0AB6C21C58D72735682-hqolJogE5njKJFWPz4pdheaU1rCVNFv4@public.gmane.org>
Content-Language: en-US
List-Unsubscribe: <https://mail.openvswitch.org/mailman/options/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://mail.openvswitch.org/pipermail/ovs-dev/>
List-Post: <mailto:ovs-dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <https://mail.openvswitch.org/mailman/listinfo/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,  Jan

I have worked out a patch, will send it quickly for Ben. In addition, I als=
o will send out a patch to change encap_nsh &decap_nsh to push_nsh and pop_=
nsh. Per comments from all the people, we all agreed to do so :-)

diff --git a/datapath/linux/compat/include/linux/openvswitch.h b/datapath/l=
inux/compat/include/linux/openvswitch.h
index bc6c94b..4936c12 100644
--- a/datapath/linux/compat/include/linux/openvswitch.h
+++ b/datapath/linux/compat/include/linux/openvswitch.h
@@ -793,7 +793,7 @@ struct ovs_action_push_eth {
        struct ovs_key_ethernet addresses;
 };

-#define OVS_ENCAP_NSH_MAX_MD_LEN 16
+#define OVS_ENCAP_NSH_MAX_MD_LEN 248
 /*
  * struct ovs_action_encap_nsh - %OVS_ACTION_ATTR_ENCAP_NSH
  * @flags: NSH header flags.
@@ -809,7 +809,7 @@ struct ovs_action_encap_nsh {
     uint8_t mdlen;
     uint8_t np;
     __be32 path_hdr;
-    uint8_t metadata[OVS_ENCAP_NSH_MAX_MD_LEN];
+    uint8_t metadata[];
 };

 /**
diff --git a/lib/odp-util.c b/lib/odp-util.c
index ef8b39d..91452f5 100644
--- a/lib/odp-util.c
+++ b/lib/odp-util.c
@@ -1785,7 +1785,8 @@ parse_odp_encap_nsh_action(const char *s, struct ofpb=
uf *actions)
 {
     int n =3D 0;
     int ret =3D 0;
-    struct ovs_action_encap_nsh encap_nsh;
+    struct ovs_action_encap_nsh *encap_nsh =3D
+        xmalloc(sizeof *encap_nsh + OVS_ENCAP_NSH_MAX_MD_LEN);
     uint32_t spi;
     uint8_t si;
     uint32_t cd;
@@ -1796,11 +1797,11 @@ parse_odp_encap_nsh_action(const char *s, struct of=
pbuf *actions)
     }

     /* The default is NSH_M_TYPE1 */
-    encap_nsh.flags =3D 0;
-    encap_nsh.mdtype =3D NSH_M_TYPE1;
-    encap_nsh.mdlen =3D NSH_M_TYPE1_MDLEN;
-    encap_nsh.path_hdr =3D htonl(255);
-    memset(encap_nsh.metadata, 0, NSH_M_TYPE1_MDLEN);
+    encap_nsh->flags =3D 0;
+    encap_nsh->mdtype =3D NSH_M_TYPE1;
+    encap_nsh->mdlen =3D NSH_M_TYPE1_MDLEN;
+    encap_nsh->path_hdr =3D htonl(255);
+    memset(encap_nsh->metadata, 0, encap_nsh->mdlen);

     for (;;) {
         n +=3D strspn(s + n, delimiters);
@@ -1808,17 +1809,17 @@ parse_odp_encap_nsh_action(const char *s, struct of=
pbuf *actions)
             break;
         }

-        if (ovs_scan_len(s, &n, "flags=3D%"SCNi8, &encap_nsh.flags)) {
+        if (ovs_scan_len(s, &n, "flags=3D%"SCNi8, &encap_nsh->flags)) {
             continue;
         }
-        if (ovs_scan_len(s, &n, "mdtype=3D%"SCNi8, &encap_nsh.mdtype)) {
-            switch (encap_nsh.mdtype) {
+        if (ovs_scan_len(s, &n, "mdtype=3D%"SCNi8, &encap_nsh->mdtype)) {
+            switch (encap_nsh->mdtype) {
             case NSH_M_TYPE1:
                 /* This is the default format. */;
                 break;
             case NSH_M_TYPE2:
                 /* Length will be updated later. */
-                encap_nsh.mdlen =3D 0;
+                encap_nsh->mdlen =3D 0;
                 break;
             default:
                 ret =3D -EINVAL;
@@ -1826,24 +1827,24 @@ parse_odp_encap_nsh_action(const char *s, struct of=
pbuf *actions)
             }
             continue;
         }
-        if (ovs_scan_len(s, &n, "np=3D%"SCNi8, &encap_nsh.np)) {
+        if (ovs_scan_len(s, &n, "np=3D%"SCNi8, &encap_nsh->np)) {
             continue;
         }
         if (ovs_scan_len(s, &n, "spi=3D0x%"SCNx32, &spi)) {
-            encap_nsh.path_hdr =3D
+            encap_nsh->path_hdr =3D
                     htonl(((spi << NSH_SPI_SHIFT) & NSH_SPI_MASK) |
-                            (ntohl(encap_nsh.path_hdr) & ~NSH_SPI_MASK));
+                            (ntohl(encap_nsh->path_hdr) & ~NSH_SPI_MASK));
             continue;
         }
         if (ovs_scan_len(s, &n, "si=3D%"SCNi8, &si)) {
-            encap_nsh.path_hdr =3D
+            encap_nsh->path_hdr =3D
                     htonl((si << NSH_SI_SHIFT) |
-                            (ntohl(encap_nsh.path_hdr) & ~NSH_SI_MASK));
+                            (ntohl(encap_nsh->path_hdr) & ~NSH_SI_MASK));
             continue;
         }
-        if (encap_nsh.mdtype =3D=3D NSH_M_TYPE1) {
+        if (encap_nsh->mdtype =3D=3D NSH_M_TYPE1) {
             struct nsh_md1_ctx *md1 =3D
-                ALIGNED_CAST(struct nsh_md1_ctx *, encap_nsh.metadata);
+                ALIGNED_CAST(struct nsh_md1_ctx *, encap_nsh->metadata);
             if (ovs_scan_len(s, &n, "c1=3D0x%"SCNx32, &cd)) {
                 put_16aligned_be32(&md1->c[0], htonl(cd));
                 continue;
@@ -1861,30 +1862,34 @@ parse_odp_encap_nsh_action(const char *s, struct of=
pbuf *actions)
                 continue;
             }
         }
-        else if (encap_nsh.mdtype =3D=3D NSH_M_TYPE2) {
+        else if (encap_nsh->mdtype =3D=3D NSH_M_TYPE2) {
             struct ofpbuf b;
             char buf[512];
             size_t mdlen;
             if (ovs_scan_len(s, &n, "md2=3D0x%511[0-9a-fA-F]", buf)) {
-                ofpbuf_use_stub(&b, encap_nsh.metadata,
+                ofpbuf_use_stub(&b, encap_nsh->metadata,
                                 OVS_ENCAP_NSH_MAX_MD_LEN);
                 ofpbuf_put_hex(&b, buf, &mdlen);
-                encap_nsh.mdlen =3D mdlen;
+                encap_nsh->mdlen =3D mdlen;
                 ofpbuf_uninit(&b);
             }
             continue;
         }
     }
 out:
-    if (ret < 0) {
-        return ret;
-    } else {
-        size_t size =3D offsetof(struct ovs_action_encap_nsh, metadata)
-                + ROUND_UP(encap_nsh.mdlen, 4);
-        nl_msg_put_unspec(actions, OVS_ACTION_ATTR_ENCAP_NSH,
-                          &encap_nsh, size);
-        return n;
+    if (ret >=3D 0) {
+        size_t size =3D sizeof(struct ovs_action_encap_nsh)
+                      + ROUND_UP(encap_nsh->mdlen, 4);
+        size_t pad_len =3D size - sizeof(struct ovs_action_encap_nsh)
+                         - encap_nsh->mdlen;
+        if (encap_nsh->mdlen > NSH_M_TYPE1_MDLEN && pad_len > 0) {
+            memset(encap_nsh->metadata + encap_nsh->mdlen, 0, pad_len);
+        }
+        nl_msg_put_unspec(actions, OVS_ACTION_ATTR_ENCAP_NSH, encap_nsh, s=
ize);
+        ret =3D n;
     }
+    free(encap_nsh);
+    return ret;
 }

 static int
@@ -6798,19 +6803,22 @@ odp_put_encap_nsh_action(struct ofpbuf *odp_actions,
                          const struct flow *flow,
                          struct ofpbuf *encap_data)
 {
-    struct ovs_action_encap_nsh encap_nsh;
-
-    encap_nsh.flags =3D flow->nsh.flags;
-    encap_nsh.mdtype =3D flow->nsh.mdtype;
-    encap_nsh.np =3D flow->nsh.np;
-    encap_nsh.path_hdr =3D htonl((ntohl(flow->nsh.spi) << NSH_SPI_SHIFT) |
+    size_t size;
+    size_t pad_len;
+    struct ovs_action_encap_nsh *encap_nsh =3D
+        xmalloc(sizeof *encap_nsh + OVS_ENCAP_NSH_MAX_MD_LEN);
+
+    encap_nsh->flags =3D flow->nsh.flags;
+    encap_nsh->mdtype =3D flow->nsh.mdtype;
+    encap_nsh->np =3D flow->nsh.np;
+    encap_nsh->path_hdr =3D htonl((ntohl(flow->nsh.spi) << NSH_SPI_SHIFT) |
                                    flow->nsh.si);

-    switch (encap_nsh.mdtype) {
+    switch (encap_nsh->mdtype) {
     case NSH_M_TYPE1: {
         struct nsh_md1_ctx *md1 =3D
-            ALIGNED_CAST(struct nsh_md1_ctx *, encap_nsh.metadata);
-        encap_nsh.mdlen =3D NSH_M_TYPE1_MDLEN;
+            ALIGNED_CAST(struct nsh_md1_ctx *, encap_nsh->metadata);
+        encap_nsh->mdlen =3D NSH_M_TYPE1_MDLEN;
         for (int i =3D 0; i < 4; i++) {
             put_16aligned_be32(&md1->c[i], flow->nsh.c[i]);
         }
@@ -6819,18 +6827,25 @@ odp_put_encap_nsh_action(struct ofpbuf *odp_actions,
     case NSH_M_TYPE2:
         if (encap_data) {
             ovs_assert(encap_data->size < OVS_ENCAP_NSH_MAX_MD_LEN);
-            encap_nsh.mdlen =3D encap_data->size;
-            memcpy(encap_nsh.metadata, encap_data->data, encap_data->size);
+            encap_nsh->mdlen =3D encap_data->size;
+            memcpy(encap_nsh->metadata, encap_data->data, encap_data->size=
);
         } else {
-            encap_nsh.mdlen =3D 0;
+            encap_nsh->mdlen =3D 0;
         }
         break;
     default:
-        encap_nsh.mdlen =3D 0;
+        encap_nsh->mdlen =3D 0;
         break;
     }
-    nl_msg_put_unspec(odp_actions, OVS_ACTION_ATTR_ENCAP_NSH,
-                      &encap_nsh, sizeof(encap_nsh));
+    size =3D sizeof(struct ovs_action_encap_nsh)
+           + ROUND_UP(encap_nsh->mdlen, 4);
+    pad_len =3D size - sizeof(struct ovs_action_encap_nsh)
+              - encap_nsh->mdlen;
+    if (pad_len > 0) {
+        memset(encap_nsh->metadata + encap_nsh->mdlen, 0, pad_len);
+    }
+    nl_msg_put_unspec(odp_actions, OVS_ACTION_ATTR_ENCAP_NSH, encap_nsh, s=
ize);
+    free(encap_nsh);
 }

 static void

-----Original Message-----
From: Jan Scheurich [mailto:jan.scheurich-IzeFyvvaP7pWk0Htik3J/w@public.gmane.org] =

Sent: Wednesday, August 9, 2017 4:32 PM
To: Ben Pfaff <blp-LZ6Gd1LRuIk@public.gmane.org>; Yang, Yi Y <yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Jiri Benc <jbenc-H+wXaHxf7aJhl2p70BpVqQ@public.gmane.org=
m>; davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org; Zolt=E1n Balogh <zoltan.balogh-IzeFyvvaP7pWk0Htik3J/w@public.gmane.org>
Subject: RE: [ovs-dev] [PATCH net-next] openvswitch: add NSH support

Hi all,

In OVS 2.8 we support only fixed size NSH MD1 context data for matching and=
 in set/copy_field actions. OVS parses an MD2 NSH header but does not make =
any TLV headers available to OF. The plan is to add support for matching/ma=
nipulating NSH MD2 TLVs through a new infrastructure of generic TLV match f=
ields that can be dynamically mapped to specific protocol TLVs, similar to =
the way this is done for GENEVE tunnel metadata TLVs today. But this is wor=
k for an upcoming OVS release.

However, in encap() and decap() NSH actions we do support MD2 format alread=
y. The encap_nsh datapath action is agnostic of the MD format. Any MD2 TLV =
metadata are provided as encap properties in the OF encap() operation. They=
 are translated by the ofproto layer and forwarded as opaque byte sequence =
in the encap_nsh datapath action.

Conversely, the decap_nsh() action pops any TLV metadata using the metadata=
 length in the NSH header.

Consequently the datapath action OVS_ACTION_ATTR_ENCAP_NSH is already decla=
red variable length:

odp_action_len(uint16_t type)
{
    switch ((enum ovs_action_attr) type) { ...
    case OVS_ACTION_ATTR_ENCAP_NSH: return ATTR_LEN_VARIABLE;
    case OVS_ACTION_ATTR_DECAP_NSH: return 0; ...
}

Unfortunately, that has only partially been reflected in the rest of the co=
de. The action struct should have a variable length metadata[] member and t=
he function odp_put_encap_nsh_action() should set the action nl_attr length=
 dynamically.

I'll provide a patch to fix that shortly.

BTW: I have no objections to renaming these datapath actions to push_nsh an=
d pop_nsh if that helps avoiding confusion with the existing encap attribut=
es on the netlink interface. But we should do that quickly as it is user-vi=
sible and affects unit test cases.

BR, Jan


> -----Original Message-----
> From: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org =

> [mailto:ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org] On Behalf Of Ben Pfaff
> Sent: Wednesday, 09 August, 2017 04:42
> To: Yang, Yi Y <yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Jiri Benc =

> <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>; davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
> Subject: Re: [ovs-dev] [PATCH net-next] openvswitch: add NSH support
> =

> To be clear, the OVS implementation is a placeholder.  It will get =

> replaced by whatever netdev implements, and that's OK.  I didn't focus =

> on making it perfect because I knew that.  Instead, I just made sure =

> it was good enough for an internal OVS implementation that doesn't fix =

> any ABI or API.  OVS can even change the user-visible action names, as =

> long as we do that soon (and encap/decap versus push/pop doesn't =

> matter to me).
> =

> The considerations for netdev are different and more permanent.
> =

> On Wed, Aug 09, 2017 at 02:05:12AM +0000, Yang, Yi Y wrote:
> > Hi, Jiri
> >
> > Thank you for your comments.
> >
> > __be32 c[4] is the name Ben Pfaff suggested, the original name is =

> > c1, c2, c3, c4, they are context data, so c seems ok, too :-)
> >
> > OVS has merged it and has the same name, maybe the better way is adding=
 comment /* Context data */ after it.
> >
> > For MD type 2, struct ovs_key_nsh is very difficult to cover it, so =

> > far we don't know how to support MD type 2 better, Geneve defined 64
> tun_metadata0-63 to handle this, those keys are parts of struct flow_tnl,=
 the highest possibility is to reuse those keys.
> >
> > So for future MD type 2, we will have two parts of keys, one is from =

> > struct ovs_key_nsh, another is from struct flow_tnl, this won't =

> > break
> the old uAPI.
> >
> > "#define OVS_ENCAP_NSH_MAX_MD_LEN 16" is changed per Ben's comment =

> > from 256, Ben thinks 256 is too big but we only support
> MD type 1 now. We still have ways to extend it, for example:
> >
> > struct ovs_action_encap_nsh * oaen =3D (struct ovs_action_encap_nsh *) =

> > malloc (sizeof(struct ovs_action_encap_nsh) + ANY_SIZE);
> >
> > nl_msg_put_unspec(actions, OVS_ACTION_ATTR_ENCAP_NSH,
> >                           oaen, sizeof(struct ovs_action_encap_nsh) =

> > + ANY_SIZE);
> >
> > In addition, we also need to consider, OVS userspace code must be =

> > consistent with here, so keeping it intact will be better, we have =

> > way
> to support dynamically extension when we add MD type 2 support.
> >
> > About action name, unfortunately, userspace data plane has named =

> > them as encap_nsh & decap_nsh, Jan, what do you think about Jiri's
> suggestion?
> >
> > But from my understanding, encap_* & decap_* are better because they =

> > corresponding to generic encap & decap actions, in addition,
> encap semantics are different from push, encap just pushed an empty =

> header with default values, users must use set_field to set the content o=
f the header.
> >
> > Again, OVS userspace code must be consistent with here, so keeping it i=
ntact will be better because OVS userspace code was there.
> >
> >
> > -----Original Message-----
> > From: netdev-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org =

> > [mailto:netdev-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org] On Behalf Of Jiri Benc
> > Sent: Tuesday, August 8, 2017 10:28 PM
> > To: Yang, Yi Y <yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> > Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org; davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
> > Subject: Re: [PATCH net-next] openvswitch: add NSH support
> >
> > On Tue,  8 Aug 2017 12:59:40 +0800, Yi Yang wrote:
> > > +struct ovs_key_nsh {
> > > +	__u8 flags;
> > > +	__u8 mdtype;
> > > +	__u8 np;
> > > +	__u8 pad;
> > > +	__be32 path_hdr;
> > > +	__be32 c[4];
> >
> > "c" is a very poor name. Please rename it to something that expresses w=
hat this field contains.
> >
> > Also, this looks like MD type 1 only. How are those fields going to =

> > work with MD type 2? I don't think MD type 2 implementation is
> necessary in this patch but I'd like to know how this is going to work =

> - it's uAPI and thus set in stone once this is merged. The uAPI needs to =
be designed with future use in mind.
> >
> > > +#define OVS_ENCAP_NSH_MAX_MD_LEN 16
> > > +/*
> > > + * struct ovs_action_encap_nsh - %OVS_ACTION_ATTR_ENCAP_NSH
> > > + * @flags: NSH header flags.
> > > + * @mdtype: NSH metadata type.
> > > + * @mdlen: Length of NSH metadata in bytes.
> > > + * @np: NSH next_protocol: Inner packet type.
> > > + * @path_hdr: NSH service path id and service index.
> > > + * @metadata: NSH metadata for MD type 1 or 2  */ struct =

> > > +ovs_action_encap_nsh {
> > > +	__u8 flags;
> > > +	__u8 mdtype;
> > > +	__u8 mdlen;
> > > +	__u8 np;
> > > +	__be32 path_hdr;
> > > +	__u8 metadata[OVS_ENCAP_NSH_MAX_MD_LEN];
> >
> > This is wrong. The metadata size is set to a fixed size by this and =

> > cannot be ever extended, or at least not easily. Netlink has =

> > attributes
> for exactly these cases and that's what needs to be used here.
> >
> > > @@ -835,6 +866,8 @@ enum ovs_action_attr {
> > >  	OVS_ACTION_ATTR_TRUNC,        /* u32 struct ovs_action_trunc. */
> > >  	OVS_ACTION_ATTR_PUSH_ETH,     /* struct ovs_action_push_eth. */
> > >  	OVS_ACTION_ATTR_POP_ETH,      /* No argument. */
> > > +	OVS_ACTION_ATTR_ENCAP_NSH,    /* struct ovs_action_encap_nsh. */
> > > +	OVS_ACTION_ATTR_DECAP_NSH,    /* No argument. */
> >
> > Use "push" and "pop", not "encap" and "decap" to be consistent with =

> > the naming in the rest of the file. We use encap and decap for
> tunnel operations. This code does not use lwtunnels, thus push and pop is=
 more appropriate.
> >
> >  Jiri
> > _______________________________________________
> > dev mailing list
> > dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
> > https://mail.openvswitch.org/mailman/listinfo/ovs-dev
> _______________________________________________
> dev mailing list
> dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
> https://mail.openvswitch.org/mailman/listinfo/ovs-dev
