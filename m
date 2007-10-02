From: Xia Yang <xiayang@ntu.edu.sg>
Subject: Re: Removing DAD in IPv6
Date: Tue, 02 Oct 2007 11:31:39 +0800
Message-ID: <1191295899.27507.10.camel@orbit6>
References: <1191210807.25398.18.camel@orbit6>
	 <20071001.204448.130861285.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: YOSHIFUJI Hideaki /
	 =?UTF-8?Q?=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E?=
	<yoshfuji@linux-ipv6.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp1.ntu.edu.sg ([155.69.5.207]:37612 "EHLO
	exsmtp1.ntu.edu.sg" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751757AbXJBDbz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 23:31:55 -0400
In-Reply-To: <20071001.204448.130861285.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I just find out this IFA_F_NODAD was not in the kernel used in my test
bed which is 2.6.17. So I tried to modify the code in ipv6/addrconf.c b=
y
myself to remove the DAD:

			if (!max_addresses ||
			    ipv6_count_addresses(in6_dev) < max_addresses)
				ifp =3D ipv6_add_addr(in6_dev, &addr, pinfo->prefix_len,
						    addr_type&IPV6_ADDR_SCOPE_MASK, 0);

			if (!ifp || IS_ERR(ifp)) {
			    in6_dev_put(in6_dev);
			    return;
			}
// --------New code ----------------
			if (!IS_ERR(ifp)) {
			    spin_lock_bh(&ifp->lock);
			    ifp->flags &=3D ~IFA_F_TENTATIVE;
			    spin_unlock_bh(&ifp->lock);
		=09
			    addrconf_join_solict(ifp->idev->dev, &ifp->addr);
			    ipv6_ifa_notify(RTM_NEWADDR, ifp);
			    //in6_ifa_put(ifp);
			    printk("New address configured.\n");
			}
// ----------end -------------------
			update_lft =3D create =3D 1;
			ifp->cstamp =3D jiffies;

			// addrconf_dad_start(ifp, RTF_ADDRCONF|RTF_PREFIX_RT);

However, even the new address is generated and assigned to the
interface, and I can read the address from the /proc interface, my firs=
t
few packets are eaten by the kernel. Only until after about 1 second,
then my packet can make its way out. Is kernel doing anything that
blocks the sending and receiving of packets during the time of DAD?
Thanks a lot!

Best Regards,

Xia Yang



On Mon, 2007-10-01 at 20:44 +0900, YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=
=E8=8B=B1=E6=98=8E wrote:
> In article <1191210807.25398.18.camel@orbit6> (at Mon, 01 Oct 2007 11=
:53:27 +0800), Xia Yang <xiayang@ntu.edu.sg> says:
>=20
> > I would like to ask for help on how to remove or disable the DAD pr=
ocess
> > properly, as long as the node can send, receive and forward packets
> > immediately after a new IPv6 address is generated. Any pointer is
> > appreciated. Thanks a lot in advance!
>=20
> IFA_F_NODAD address flag might help this.
>=20
> --yoshfuji
