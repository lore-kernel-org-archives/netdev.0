From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 54491] New: UFO (UDP fragmentation offload) does not work
 if the payload size specified is within the range ( (MTU-28)  to (MTU-8) )
Date: Tue, 26 Feb 2013 07:46:06 -0800
Message-ID: <20130226074606.4d16ebfb@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:55832 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759657Ab3BZPqc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2013 10:46:32 -0500
Received: by mail-pa0-f45.google.com with SMTP id kl14so2513420pab.32
        for <netdev@vger.kernel.org>; Tue, 26 Feb 2013 07:46:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Tue, 26 Feb 2013 00:52:33 -0800
=46rom: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla=
=2Ekernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 54491] New: UFO (UDP fragmentation offload) does not work=
 if the payload size specified is within the range ( (MTU-28)  to (MTU-=
8) )


https://bugzilla.kernel.org/show_bug.cgi?id=3D54491

           Summary: UFO (UDP fragmentation offload) does not work if th=
e
                    payload size specified is within the range ( (MTU-2=
8)
                    to (MTU-8) )
           Product: Networking
           Version: 2.5
    Kernel Version: 3.3.4
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
        AssignedTo: shemminger@linux-foundation.org
        ReportedBy: hnk437@gmail.com
        Regression: No


=46or IPv4/UDP if the payload size specified is within the range ( (MTU=
-28)=20
to (MTU-8) ) packet gets segmented in kernel even if the following netd=
ev
features are set:

NETIF_F_SG=20
NETIF_F_GEN_CSUM=20
NETIF_F_UFO=20
NETIF_F_TSO=20
NETIF_F_GSO=20
NETIF_F_GSO_ROBUST

Analysis:
udp_sendmsg() computes packet length by adding UDP header size to paylo=
ad size:
=E2=80=9Culen +=3D sizeof(struct udphdr)=E2=80=9D
Then the function calls ip_make_skb(), however IP header size is not ad=
ded to
the packet length.
ip_make_skb() in turn calls __ip_append_data(). The same packet length =
is used
here.=20
__ip_append_data() compares the packet length with MTU. The packet leng=
th still
does not include IP header size (20 bytes).
In result, when payload size =E2=80=9Cis within the range ( (MTU-28) to=
 (MTU-8) )=E2=80=9D
standard branch is taken rather than ip_ufo_append_data(). Gso_size is =
not
computed, therefore IP fragmentation is triggered from ip_finish_output=
().

The issue was reproduced on 3.4.3 as well

--=20
Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=3Demai=
l
------- You are receiving this mail because: -------
You are the assignee for the bug.
