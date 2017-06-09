From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net-next 1/8] qed: LL2 to use packed information for tx
Date: Fri, 9 Jun 2017 07:08:54 +0000
Message-ID: <BLUPR0701MB200415C3D80FB06774CF2C7B8DCE0@BLUPR0701MB2004.namprd07.prod.outlook.com>
References: <20170608161323.7597-1-Yuval.Mintz@cavium.com>
        <20170608161323.7597-2-Yuval.Mintz@cavium.com>
 <20170608.192358.1444190196602150329.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "Kalderon, Michal" <Michal.Kalderon@cavium.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0052.outbound.protection.outlook.com ([104.47.36.52]:58024
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751591AbdFIHJJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 9 Jun 2017 03:09:09 -0400
In-Reply-To: <20170608.192358.1444190196602150329.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > +struct qed_ll2_tx_pkt_info {
> > +	u8 num_of_bds;
> > +	u16 vlan;
> > +	u8 bd_flags;
> > +	u16 l4_hdr_offset_w;	/* from start of packet */
> > +	enum qed_ll2_tx_dest tx_dest;
> > +	enum qed_ll2_roce_flavor_type qed_roce_flavor;
> > +	dma_addr_t first_frag;
> > +	u16 first_frag_len;
> > +	bool enable_ip_cksum;
> > +	bool enable_l4_cksum;
> > +	bool calc_ip_len;
> > +	void *cookie;
> > +};
> > +
>=20
> This layout is extremely inefficient, with lots of padding in between str=
uct
> members.
>=20
> Group small u8 members and u16 members together so that they consume
> full 32-bit areas so you can eliminate all of the padding.

While I can mend the holes, the total structure size doesn't really change:

struct qed_ll2_tx_pkt_info {
        u8                         num_of_bds;           /*     0     1 */

        /* XXX 1 byte hole, try to pack */

        u16                        vlan;                 /*     2     2 */
        u8                         bd_flags;             /*     4     1 */

        /* XXX 1 byte hole, try to pack */

        u16                        l4_hdr_offset_w;      /*     6     2 */
        enum qed_ll2_tx_dest       tx_dest;              /*     8     4 */
        enum qed_ll2_roce_flavor_type qed_roce_flavor;   /*    12     4 */
        dma_addr_t                 first_frag;           /*    16     8 */
        u16                        first_frag_len;       /*    24     2 */
        bool                       enable_ip_cksum;      /*    26     1 */
        bool                       enable_l4_cksum;      /*    27     1 */
        bool                       calc_ip_len;          /*    28     1 */

        /* XXX 3 bytes hole, try to pack */

        void *                     cookie;               /*    32     8 */

        /* size: 40, cachelines: 1, members: 12 */
        /* sum members: 35, holes: 3, sum holes: 5 */
        /* last cacheline: 40 bytes */
};

Becomes:

struct qed_ll2_tx_pkt_info {
        void *                     cookie;               /*     0     8 */
        dma_addr_t                 first_frag;           /*     8     8 */
        enum qed_ll2_tx_dest       tx_dest;              /*    16     4 */
        enum qed_ll2_roce_flavor_type qed_roce_flavor;   /*    20     4 */
        u16                        vlan;                 /*    24     2 */
        u16                        l4_hdr_offset_w;      /*    26     2 */
        u16                        first_frag_len;       /*    28     2 */
        u8                         num_of_bds;           /*    30     1 */
        u8                         bd_flags;             /*    31     1 */
        bool                       enable_ip_cksum;      /*    32     1 */
        bool                       enable_l4_cksum;      /*    33     1 */
        bool                       calc_ip_len;          /*    34     1 */

        /* size: 40, cachelines: 1, members: 12 */
        /* padding: 5 */
        /* last cacheline: 40 bytes */
};

I'm going to send the changed version in V2 as as there's no harm to it,
[+ we *can* reduce the size of qed_ll2_comp_rx_data you commented
for patch #2 in series]

But one thing I thought of asking - do we consider layouts of relatively
insignificant structures to be some golden coding standard?
