From: =?UTF-8?B?Q2hpYS1jaGkgWWVoICjokYnlrrbpvYop?= <chiachi@android.com>
Subject: Re: [PATCH] net: Keep interface binding when sending packets with
	ipi_ifindex = 0
Date: Tue, 4 Aug 2009 15:36:46 +0800
Message-ID: <6c039e090908040036j38666152y2db1d4c55529eaff@mail.gmail.com>
References: <6c039e090907231439t1def08a4n10978733bee55bec@mail.gmail.com>
	 <20090727144402.513369f1.akpm@linux-foundation.org>
	 <1248912621.13447.12.camel@merlyn>
	 <20090803.212323.256579233.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: john.dykstra1@gmail.com, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932670AbZHDHgr@vger.kernel.org>
In-Reply-To: <20090803.212323.256579233.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After thinking more deeply, I believe that IPv6 does the right thing
and IPv4 does not. SO_BINDTODEVICE requires CAP_NET_RAW, so it is a
privileged operation. Therefore, it looks weird to me if one can
specify other interface than the bound one without the same
capability. The following patch makes the behavior in IPv4 and IPv6
identical. Thanks for your help.

Chia-chi

--- a/net/ipv4/ip_sockglue.c    2009-08-04 15:11:39.000000000 +0800
+++ b/net/ipv4/ip_sockglue.c    2009-08-04 15:17:05.000000000 +0800
@@ -213,7 +213,11 @@
                        if (cmsg->cmsg_len !=3D CMSG_LEN(sizeof(struct
in_pktinfo)))
                                return -EINVAL;
                        info =3D (struct in_pktinfo *)CMSG_DATA(cmsg);
-                       ipc->oif =3D info->ipi_ifindex;
+                       if (info->ipi_ifindex) {
+                               if (ipc->oif && info->ipi_ifindex !=3D =
ipc->oif)
+                                       return -EINVAL;
+                               ipc->oif =3D info->ipi_ifindex;
+                       }
                        ipc->addr =3D info->ipi_spec_dst.s_addr;
                        break;
                }

On Tue, Aug 4, 2009 at 12:23 PM, David Miller<davem@davemloft.net> wrot=
e:
> From: John Dykstra <john.dykstra1@gmail.com>
> Date: Wed, 29 Jul 2009 19:10:21 -0500
>
>> I guess Dave's letting this stand. =A0I'm posting this just to make =
sure
>> this is an explicit decision.
>
> I'm still thinking about this.
>
