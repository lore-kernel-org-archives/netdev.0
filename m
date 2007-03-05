From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 001 of 3] knfsd: Use recv_msg to get peer address
	for NFSD instead of code-copying
Date: Tue, 6 Mar 2007 08:09:12 +1100
Message-ID: <17900.34552.69250.247125@notabene.brown>
References: <20070302151748.5226.patches@notabene> <1070302042825.5760@suse.de>
	<200703051959.56914.olaf.kirch@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: Olaf Kirch <olaf.kirch@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
In-Reply-To: message from Olaf Kirch on Monday March 5
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Monday March 5, olaf.kirch@oracle.com wrote:
> 
> Hi Neil,
> 
> here's another minor comment:
> 
> On Friday 02 March 2007 05:28, NeilBrown wrote:
> > +static inline void svc_udp_get_dest_address(struct svc_rqst *rqstp,
> > +					    struct cmsghdr *cmh)
> >  {
> >  	switch (rqstp->rq_sock->sk_sk->sk_family) {
> >  	case AF_INET: {
> > +		struct in_pktinfo *pki = CMSG_DATA(cmh);
> > +		rqstp->rq_daddr.addr.s_addr = pki->ipi_spec_dst.s_addr;
> >  		break;
> > +		}
> ...
> 
> The daddr that is extracted here will only ever be used to build
> another PKTINFO cmsg when sending the reply. So it would be
> much easier to just store the raw control message in the svc_rqst,
> without looking at its contents, and send it out along with the reply,
> unchanged.

Yes, sounds tempting, doesn't it?
Unfortunately it isn't that simple as I found out when the sunrpc code
in glibc did exactly that.

You see sendmsg will use the interface-number as well as the source
address from the PKTINFO structure.

Suppose my server has two interfaces (A and B) on two subnets that
both are connected to some router which is connected to a third subnet
that my client is on.  Further, suppose my server has only one default
route, out interface A.
The client chooses the IP address of interface B and sends a request.
It arrives on interface B and is processed.
If the PKTINFO received is passed unchanged to sendmsg, the pack will
be sent out interface B.  But interfacve B doesn't have a route to
that client, so the packet is dropped.

This exactly what was happening for me with mountd a few years ago.

So yes, we could just zero the interface field, but I think it is
clearer to extract that wanted data, then re-insert it.  They really
are different structures with different meanings (send verse receive)
which happen to have the same layout.

Thanks,
NeilBrown


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
