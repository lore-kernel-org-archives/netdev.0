From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: WARNING: at net/ipv4/af_inet.c:154 inet_sock_destruct
Date: Fri, 30 Oct 2009 15:55:51 +0100
Message-ID: <4AEAFE77.9030205@gmail.com>
References: <38b2ab8a0909290109m3f82c161j4fb0f1266152877e@mail.gmail.com>	 <4AC1D0F5.4050709@gmail.com>	 <38b2ab8a0910300144i7a3c190fi9aa3d079c9cdb754@mail.gmail.com>	 <4AEACD88.8080108@gmail.com>	 <38b2ab8a0910300533l4bbc9d3cj8812fe38726c8278@mail.gmail.com> <38b2ab8a0910300641q78c08124o800a9dfc9486fba7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Francis Moreau <francis.moro@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932315AbZJ3Ozw@vger.kernel.org>
In-Reply-To: <38b2ab8a0910300641q78c08124o800a9dfc9486fba7@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rancis Moreau a =E9crit :
> On Fri, Oct 30, 2009 at 1:33 PM, Francis Moreau <francis.moro@gmail.c=
om> wrote:
>> On Fri, Oct 30, 2009 at 12:27 PM, Eric Dumazet <eric.dumazet@gmail.c=
om> wrote:
>>> This oops occurring again and again with SUNRPC finally gave me the=
 right pointer.
>>>
>>> David, we added two years ago memory accounting to UDP, and this ch=
anged
>>> requirements about calling skb_free_datagram() in the right context=
=2E
>>>
>>> I wish we had an ASSERT_SOCK_LOCKED() debugging facility :(
>>>
>>> Francis, would you please test following patch ?
>> I'm applying it and testing it during a couple of days and see if
>> something wrong still happens.
>=20
> Hmm, with the patch applied on a 2.6.32-rc5, my machine locks hard
> when starting nfsd.
>=20

Please ignore/revert the last part of the patch (about net/sunrpc/xprts=
ock.c)

In xs_udp_data_ready() we really want to call skb_free_datagram(),
not skb_free_datagram_locked(), because socket is already locked.

Thanks

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 37c5475..d61be4a 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -883,7 +883,7 @@ static void xs_udp_data_ready(struct sock *sk, int =
len)
  out_unlock:
 	spin_unlock(&xprt->transport_lock);
  dropit:
+	skb_free_datagram(sk, skb);
-	skb_free_datagram_locked(sk, skb);
  out:
 	read_unlock(&sk->sk_callback_lock);
 }
