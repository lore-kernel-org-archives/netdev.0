From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH stable <= 3.18] net: add length argument to
 skb_copy_and_csum_datagram_iovec
Date: Thu, 12 Nov 2015 09:26:42 -0800
Message-ID: <1447349202.22599.30.camel@edumazet-glaptop2.roam.corp.google.com>
References: <c1b23313f94ba3fd9977c6fba61483edf6489b5f.1444910940.git.sd@queasysnail.net>
	 <20151029100021.GA17588@bistromath.redhat.com>
	 <CAKA=qzZCi_OEDJKgy1WQ1QdMBpHBure1tY7NYtsgSr0fMva5jQ@mail.gmail.com>
	 <20151111000352.GA5134@kroah.com>
	 <20151112094822.GA21732@bistromath.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Josh Hunt <joshhunt00@gmail.com>, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au, stable <stable@vger.kernel.org>,
	hannes@stressinduktion.org
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20151112094822.GA21732@bistromath.redhat.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-11-12 at 10:48 +0100, Sabrina Dubroca wrote:
> 2015-11-10, 16:03:52 -0800, Greg Kroah-Hartman wrote:
> > On Tue, Nov 10, 2015 at 05:59:26PM -0600, Josh Hunt wrote:
> > > On Thu, Oct 29, 2015 at 5:00 AM, Sabrina Dubroca <sd@queasysnail.net> wrote:
> > > > 2015-10-15, 14:25:03 +0200, Sabrina Dubroca wrote:
> > > >> Without this length argument, we can read past the end of the iovec in
> > > >> memcpy_toiovec because we have no way of knowing the total length of the
> > > >> iovec's buffers.
> > > >>
> > > >> This is needed for stable kernels where 89c22d8c3b27 ("net: Fix skb
> > > >> csum races when peeking") has been backported but that don't have the
> > > >> ioviter conversion, which is almost all the stable trees <= 3.18.
> > > >>
> > > >> This also fixes a kernel crash for NFS servers when the client uses
> > > >>  -onfsvers=3,proto=udp to mount the export.
> > > >>
> > > >> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
> > > >> Reviewed-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > > >
> > > > Fixes CVE-2015-8019.
> > > > http://www.openwall.com/lists/oss-security/2015/10/29/1
> > > >
> > > > --
> > > > Sabrina
> > > > --
> > > > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > > > the body of a message to majordomo@vger.kernel.org
> > > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > > 
> > > Greg
> > > 
> > > Do you have this in your queue? I saw a few other stables pick this
> > > up, but haven't seen it in 3.14 or 3.18 yet. It wasn't clear to me if
> > > this had been fully reviewed yet.
> > 
> > I rely on Dave to package up networking stable patches and forward them
> > on to me, that's why you haven't seen it be picked up yet.
> > 
> > thanks,
> > 
> > greg k-h
> 
> David, can you queue this up?
> 

Note that the following patch (and corresponding part for ipv6) might
also have solve the issue ?

This would supposedly save some cycles when MSG_PEEK is used and user
provides short buffers.

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 24ec14f9825c..387acab1ab5c 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1272,6 +1272,7 @@ int udp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int noblock,
 	int err;
 	int is_udplite = IS_UDPLITE(sk);
 	bool slow;
+	bool checksum_valid = false;
 
 	if (flags & MSG_ERRQUEUE)
 		return ip_recv_error(sk, msg, len, addr_len);
@@ -1296,11 +1297,12 @@ try_again:
 	 */
 
 	if (copied < ulen || UDP_SKB_CB(skb)->partial_cov) {
-		if (udp_lib_checksum_complete(skb))
+		checksum_valid = !udp_lib_checksum_complete(skb);
+		if (!checksum_valid)
 			goto csum_copy_err;
 	}
 
-	if (skb_csum_unnecessary(skb))
+	if (checksum_valid || skb_csum_unnecessary(skb))
 		err = skb_copy_datagram_msg(skb, sizeof(struct udphdr),
 					    msg, copied);
 	else {
