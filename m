From: TAKANO Ryousei <takano@axe-inc.co.jp>
Subject: Re: [PATCH 7/7] [TCP]: Limit processing lost_retrans loop to
 work-to-do cases
Date: Thu, 18 Oct 2007 12:50:45 +0900 (JST)
Message-ID: <20071018.125045.90803775.takano@axe-inc.co.jp>
References: <11921028671668-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1192102867248-git-send-email-ilpo.jarvinen@helsinki.fi>
	<20071011.173622.09942622.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ilpo.jarvinen@helsinki.fi, y-kodama@aist.go.jp,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from axekw.axe-inc.co.jp ([61.199.217.67]:58074 "EHLO
	axekw.axe-inc.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754736AbXJRDux convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2007 23:50:53 -0400
In-Reply-To: <20071011.173622.09942622.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/7] [TCP]: Limit processing lost_retrans loop to w=
ork-to-do cases
Date: Thu, 11 Oct 2007 17:36:22 -0700 (PDT)

> From: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Thu, 11 Oct 2007 14:41:07 +0300
>=20
> > This addition of lost_retrans_low to tcp_sock might be
> > unnecessary, it's not clear how often lost_retrans worker is
> > executed when there wasn't work to do.
> >=20
> > Cc: TAKANO Ryousei <takano@axe-inc.co.jp>
> > Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
>=20
> Applied.

> +	    after(highest_sack_end_seq, tp->lost_retrans_low) &&

This limit degrades the performance of my test case described before,
since it misses opportunities of detecting loss of retransmitted packet=
s.

The results are shown as follows:

linux-2.6.23
iteration :001 .... done. T =3D 19.758205 BW =3D 404.895077 Mbps
iteration :002 .... done. T =3D 19.241735 BW =3D 415.762924 Mbps
iteration :003 .... done. T =3D 18.998427 BW =3D 421.087495 Mbps
iteration :004 .... done. T =3D 18.971502 BW =3D 421.685113 Mbps
iteration :005 .... done. T =3D 19.298313 BW =3D 414.544009 Mbps

net-2.6 (current):
iteration :001 .... done. T =3D 43.672971 BW =3D 183.179660 Mbps
iteration :002 .... done. T =3D 16.668652 BW =3D 479.942828 Mbps
iteration :003 .... done. T =3D 25.569106 BW =3D 312.877581 Mbps
iteration :004 .... done. T =3D 55.314832 BW =3D 144.626671 Mbps
iteration :005 .... done. T =3D 35.377025 BW =3D 226.135464 Mbps

net-2.6 (no limit)
iteration :001 .... done. T =3D 16.907727 BW =3D 473.156445 Mbps
iteration :002 .... done. T =3D 16.662908 BW =3D 480.108272 Mbps
iteration :003 .... done. T =3D 16.536396 BW =3D 483.781350 Mbps
iteration :004 .... done. T =3D 16.565220 BW =3D 482.939560 Mbps
iteration :005 .... done. T =3D 16.528676 BW =3D 484.007309 Mbps

"no limit" does as follows:
        if (tp->retrans_out && highest_sack_end_seq &&
            icsk->icsk_ca_state =3D=3D TCP_CA_Recovery)
                flag |=3D tcp_mark_lost_retrans(sk, highest_sack_end_se=
q);

Ryousei Takano
