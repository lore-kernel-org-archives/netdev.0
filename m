From: "Eric Barton" <eeb@bartonsoftware.com>
Subject: tcp retransmission
Date: Tue, 21 Dec 2004 19:08:33 -0000
Message-ID: <005d01c4e790$78030ff0$0281a8c0@ebpc>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

Can someone please help me understand this code in tcp_output.c...

int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
{
	struct tcp_opt *tp = tcp_sk(sk);
 	unsigned int cur_mss = tcp_current_mss(sk, 0);
	int err;

	/* Do not sent more than we queued. 1/4 is reserved for possible
	 * copying overhead: frgagmentation, tunneling, mangling etc.
	 */
	if (atomic_read(&sk->sk_wmem_alloc) >
	    min(sk->sk_wmem_queued + (sk->sk_wmem_queued >> 2), sk->sk_sndbuf))
		return -EAGAIN;


...it's the decision to return -EAGAIN that has me baffled.  AFAIK
sk_wmem_queued is the number of unacknowledged bytes buffered for sending,
wherease sk_wmwm_alloc is the total number of bytes allocated for buffering
sends.  How does this comparison make sense?

I ask because I'm trying to investigate a TCP hangup, where (for some reason)
the NIC fails to send an skb, but all the retransmit attempts fail because this
condition traps them.


Also, when trawling through the code to trying to understand some context, I
came across the following in tcp_retransmit_timer()...

	if (tcp_retransmit_skb(sk, skb_peek(&sk->sk_write_queue)) > 0) {
		/* Retransmission failed because of local congestion,
		 * do not backoff.
		 */

...maybe I'm being blind but I don't quite get under which circumstances
tcp_retransmit_skb() can return > 0.

Thanks in advance...
