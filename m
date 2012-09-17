From: Yi Li <lovelylich@gmail.com>
Subject: [TCP]: functionality of delayed_ack in Bic and Cubic Algorithm ?
Date: Mon, 17 Sep 2012 10:34:34 +0800
Message-ID: <50568C3A.9060908@gmail.com>
References: <5056897A.9010009@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:35522 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753089Ab2IQCem (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2012 22:34:42 -0400
Received: by oago6 with SMTP id o6so4300936oag.19
        for <netdev@vger.kernel.org>; Sun, 16 Sep 2012 19:34:41 -0700 (PDT)
In-Reply-To: <5056897A.9010009@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,
I am try to understand the patch:
http://patchwork.usersys.redhat.com/patch/43827/.
But I am not sure of the functionality of delayed_ack filed in Bic and
Cubic.
I have found the following mails:
http://oss.sgi.com/archives/netdev/2005-02/msg00808.html
which is the first patch introducing the *delayed_ack* field.
( But I am not fully understand that material, That's why I have asked
here.)

So, here is my understanding of this field, and I am not sure whether it
is right. :-(
Question One:
>From comment in *struct bictcp*, delayed_ack is "the ratio of
Packets/ACKs << 4"
and it's updating is in function bictcp_acked():

    /* Track delayed acknowledgment ratio using sliding window
    * ratio = (15*ratio + sample) / 16
    */
    static void bictcp_acked(struct sock *sk, u32 cnt, s32 rtt_us)
    {
    const struct inet_connection_sock *icsk = inet_csk(sk);
    const struct tcp_sock *tp = tcp_sk(sk);
    struct bictcp *ca = inet_csk_ca(sk);
    u32 delay;

    if (icsk->icsk_ca_state == TCP_CA_Open) {
    cnt -= ca->delayed_ack >> ACK_RATIO_SHIFT;
    ca->delayed_ack += cnt;
    }

After googling, I know ratio == delayed_ack >> ACK_RATIO_SHIFT. so here
we are updating
the Packets/Acks ratio, basing on the history of ratio (15/16) and the
current ratio(1/16).
The current ratio is cnt packets acked by the current acknowledgement,
divided by the current
count of acknowledgements(of course it is 1 ack packet). Right?

Question Two:
And we update the ca->cnt in function bictcp_update():
ca->cnt = (ca->cnt << ACK_RATIO_SHIFT) / ca->delayed_ack;
if (ca->cnt == 0) /* cannot be zero */
ca->cnt = 1;
It means ca->cnt= ca->cnt * Acks/Packets. Suppose normal delayed ack,
Acks/Packets should be 1/2.
So, ca->cnt will be cut in half. As a result, snd_cwnd will increase one
times more rapidly, and this is just a
compensation for delayed ack. So, TCP will still work normally. Right?
