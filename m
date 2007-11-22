From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH net-2.6.25] Add packet filtering based on process's
 security context.
Date: Fri, 23 Nov 2007 10:29:46 +1100 (EST)
Message-ID: <Xine.LNX.4.64.0711231005270.4252@us.intercode.com.au>
References: <200711212130.EJJ43745.LFOFHOSMJOtFVQ@I-love.SAKURA.ne.jp>
 <200711222235.GCA05378.HtMOJQVFSFOLFO@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	linux-security-module@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	netfilter-devel@lists.netfilter.org,
	Stephen Smalley <sds@tycho.nsa.gov>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <200711222235.GCA05378.HtMOJQVFSFOLFO@I-love.SAKURA.ne.jp>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 22 Nov 2007, Tetsuo Handa wrote:

> This patch allows LSM modules filter incoming connections/datagrams
> based on the process's security context who is attempting to pick up.
> 
> There are already hooks to filter incoming connections/datagrams
> based on the socket's security context, but these hooks are not
> applicable when one wants to do TCP Wrapper-like filtering
> (e.g. App1 is permitted to accept TCP connections from 192.168.0.0/16).

This functionality looks like it could be useful in that we currently have 
no direct security mapping from incoming packet to user process, but only 
to the receiving socket, as you mention.  For SELinux, it may help us 
simplify/clarify policy.

It's also been long-desired for netfilter/iptables, to allow ipt_owner to 
work cleanly for incoming packets.

So, this probably needs to be implemented in a way which works for both LSM 
and netfilter.  There have been several discussions on the issue from the 
netfilter side, although I don't know what the latest status of that is 
(I've expanded the cc list to hopefully get some more feedback).

>From memory, one approach under discussion was to add netfilter hooks to 
the transport layer, which could be invoked correctly by each type of 
protocol when the target process is selected.

If this is done for netfilter, then an LSM hook is probably not needed at 
all, as security modules can utilize netfilter hooks directly.

> Precautions: This approach has a side effect which unlikely occurs.
> 
> If a socket is shared by multiple processes with differnt policy,
> the process who should be able to accept this connection
> will not be able to accept this connection
> because socket_post_accept() aborts this connection.
> But if socket_post_accept() doesn't abort this connection,
> the process who must not be able to accept this connection
> will repeat accept() forever, which is a worse side effect.
> 
> Similarly, if a socket is shared by multiple processes with differnt policy,
> the process who should be able to pick up this datagram
> will not be able to pick up this datagram
> because socket_post_recv_datagram() discards this datagram.
> But if socket_post_recv_datagram() doesn't discard this datagram,
> the process who must not be able to pick up this datagram
> will repeat recvmsg() forever, which is a worse side effect.
> 
> So, don't give different permissions between processes who share one socket.
> Otherwise, some connections/datagrams cannot be delivered to intended process.

These semantics changes are concerning, and lead me to wonder if there are 
any more.  Needs more review by networking folk.



- James
-- 
James Morris
<jmorris@namei.org>
