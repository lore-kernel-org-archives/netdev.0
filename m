From: Hannes Frederic Sowa <hannes@redhat.com>
Subject: Re: net/unix: sk_socket can disappear when state is unlocked
Date: Fri, 22 May 2015 17:35:15 +0200
Message-ID: <1432308915.28081.10.camel@redhat.com>
References: <1432225541-28498-1-git-send-email-salyzyn@android.com>
	 <1432288230.3364.23.camel@redhat.com> <555F4267.30704@android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Al Viro <viro@zeniv.linux.org.uk>,
	David Howells <dhowells@redhat.com>,
	Ying Xue <ying.xue@windriver.com>,
	Christoph Hellwig <hch@lst.de>, netdev@vger.kernel.org
To: Mark Salyzyn <salyzyn@android.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <555F4267.30704@android.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fr, 2015-05-22 at 07:51 -0700, Mark Salyzyn wrote:
> On 05/22/2015 02:50 AM, Hannes Frederic Sowa wrote:
> > On Do, 2015-05-21 at 09:25 -0700, Mark Salyzyn wrote:
> >> got a rare NULL pointer dereference in clear_bit
> >>
> >> Signed-off-by: Mark Salyzyn <salyzyn@android.com>
> >> ---
> >>   net/unix/af_unix.c | 5 +++++
> >>   1 file changed, 5 insertions(+)
> >>
> >> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> >> index 5266ea7..37a8925 100644
> >> --- a/net/unix/af_unix.c
> >> +++ b/net/unix/af_unix.c
> >> @@ -1880,6 +1880,11 @@ static long unix_stream_data_wait(struct sock *sk, long timeo,
> >>   		unix_state_unlock(sk);
> >>   		timeo = freezable_schedule_timeout(timeo);
> >>   		unix_state_lock(sk);
> >> +
> >> +		/* sk_socket may have been killed while unlocked */
> >> +		if (!sk->sk_socket)
> >> +			break;
> >> +
> >>   		clear_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
> >>   	}
> >>   
> > Canonical way is to test for sock_flag(sk, SOCK_DEAD). Also it does not
> > seem like we are returning an error to user space but are still looping
> > to try to dequeue skbs from sk_receive_queue, which is concurrently
> > emptied by unix_release (maybe, without holding unix_state_lock).
> >
> > Bye,
> > Hannes
> >
> I will send an updated patch shortly.
> 
> It may be acceptable given the expectation that sk_set_socket(sk, NULL) 
> occurs after SOCK_DEAD flag is set since we would not be here during the 
> socket initialization/connection phases. As such, for all phases (and I 
> re-iterate, we can only be here if in connected state), it is not a 
> generic guarantee of sk_socket != NULL. But I only saw one apparent 
> example (in net/decnet/dn_nsp_in.c) of using sock_flag(sk, SOCK_DEAD) as 
> protection against a possible deference NULL access with sk_socket, and 
> many KISS examples of checking sk_socket for NULL to protect against thus.
> 
> Thanks for making me look though, it appears that I missed the same 
> problem in net/caif/caif_socket.c and will add it!

Thank you for v2 of the patch.

I still wonder if we need to actually recheck the condition and not
simply break out of unix_stream_data_wait:

We return to the unix_stream_recvmsg loop and recheck the
sk_receive_queue. At this point sk_receive_queue is not really protected
with unix_state_lock against concurrent modification with unix_release,
as such we could end up concurrently dequeueing packets if socket is
DEAD.

Does that make sense?

Thanks,
Hannes
