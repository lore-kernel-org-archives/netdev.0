From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [RFC] moving the test for sockaddr->sa_family up
Date: Sun, 16 Nov 2003 17:07:58 -0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031116190757.GA18416@conectiva.com.br>
References: <20031115212034.GA16326@conectiva.com.br> <Xine.LNX.4.44.0311160855020.31201-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
Content-Disposition: inline
In-Reply-To: <Xine.LNX.4.44.0311160855020.31201-100000@thoron.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Sun, Nov 16, 2003 at 08:56:04AM -0500, James Morris escreveu:
> On Sat, 15 Nov 2003, Arnaldo Carvalho de Melo wrote:
> 
> > Does anybody see any problem with this simplification? Not for 2.6.0, of
> > course...
> 
> No, looks like a good idea.  Might be able to push address length 
> verification up there too.

Not really, look at the ax25 code... :-\ They have to support two address types,
if we want to keep this flexibility we can't check it at the upper layer,
does anybody here knows if we want or if we can ditch that thing in ax25? this:

net/ax25/af_ax25.c

static int ax25_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
{
        struct sock *sk = sock->sk;
        struct full_sockaddr_ax25 *addr = (struct full_sockaddr_ax25 *)uaddr;
        ax25_dev *ax25_dev = NULL;
        ax25_address *call;
        ax25_cb *ax25;
        int err = 0;

        if (addr_len != sizeof(struct sockaddr_ax25) &&
            addr_len != sizeof(struct full_sockaddr_ax25)) {
                /* support for old structure may go away some time */
                if ((addr_len < sizeof(struct sockaddr_ax25) + sizeof(ax25_address) * 6) ||
                    (addr_len > sizeof(struct full_sockaddr_ax25))) {
                        return -EINVAL;
        }

                printk(KERN_WARNING "ax25_bind(): %s uses old (6 digipeater) socket structure.\n",
                        current->comm);
        }


I haven't checked for how many major kernel versions this thing is there, but
I'd love to trow this away if possible.

Ah, I tried to see if we could move the family test in the ->connect case as
well, only to enlighten myself with a trick in PF_UNIX, namely:

static int unix_dgram_connect(struct socket *sock, struct sockaddr *addr,
                              int alen, int flags)
<SNIP>
        if (addr->sa_family != AF_UNSPEC) {
<SNIP>
	        } else {
                /*
                 *      1003.1g breaking connected state with AF_UNSPEC
                 */
                other = NULL;
                unix_state_wlock(sk);
        }

Oh well, the thing uses sa_family to a magic value to signal breaking connected
state, the wonders never cease :(

- Arnaldo
