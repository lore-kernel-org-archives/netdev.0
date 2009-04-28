From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] poll: Avoid extra wakeups in select/poll
Date: Tue, 28 Apr 2009 22:05:08 +0200
Message-ID: <49F76174.6060009@cosmosbay.com>
References: <alpine.DEB.1.10.0904241554100.29995@qirst.com> <49F3308B.1030507@cosmosbay.com> <20090426.020411.157511269.davem@davemloft.net> <49F43B8F.2050907@cosmosbay.com> <87ab60rh8t.fsf@basil.nowhere.org> <49F71B63.8010503@cosmosbay.com> <alpine.DEB.1.10.0904281501300.13862@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux kernel <linux-kernel@vger.kernel.org>,
	Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, jesse.brandeburg@intel.com,
	netdev@vger.kernel.org, haoki@redhat.com, mchan@broadcom.com,
	davidel@xmailserver.org, Ingo Molnar <mingo@elte.hu>
To: Christoph Lameter <cl@linux.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755398AbZD1UGg@vger.kernel.org>
In-Reply-To: <alpine.DEB.1.10.0904281501300.13862@qirst.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christoph Lameter a =E9crit :
> For the udpping test load these patches have barely any effect:
>=20
> git2p1 is the first version of the patch
> git2p2 is the second version (this one)

But... udpping does *not* use poll() nor select(), unless I am mistaken=
 ?

If you really want to test this patch with udpping, you might add a pol=
l() call
before recvfrom() :

                while(1) {
+                       struct pollfd pfd =3D { .fd =3D sock, .events =3D=
 POLLIN};
+                       poll(pfd, 1, -1);
                        nbytes =3D recvfrom(sock, msg, min(inblocksize,=
 sizeof(msg)),
                                                                0, &ina=
d, &inadlen);
                        if (nbytes < 0) {
                                perror("recvfrom");
                                break;
                        }
                        if (sendto(sock, msg, nbytes, 0, &inad, inadlen=
) < 0) {
                                perror("sendto");
                                break;
                        }
                }

Part about recvfrom() wakeup avoidance is in David net-2.6 tree, and sa=
ves 2 us on udpping here.

Is it what you call git2p1 ?
