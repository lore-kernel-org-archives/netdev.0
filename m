From: Craig Gallek <kraig@google.com>
Subject: Re: Crash with SO_REUSEPORT and ef456144da8ef507c8cf504284b6042e9201a05c
Date: Tue, 19 Jan 2016 13:11:31 -0500
Message-ID: <CAEfhGiy=-AgMad_tquyXws7Vf3j9HWwhCnaZqWeq58_XSzcgoA@mail.gmail.com>
References: <CAB9dFdugvFvdQLGAU83CQHYbwaWCMHrAm5Xk746iwMG5g94PqQ@mail.gmail.com>
	<CAB9dFdswyri4-pDZ+uoAk00isP8Lba7-uqYPXnT=PnLataJeHg@mail.gmail.com>
	<CAEfhGixbKf7+j_4KUvNSQL96N+-9SsDSaH0CmfL=iwWFAYDeMg@mail.gmail.com>
	<CAB9dFdsVxzi_Tx2yvStXLr2qvqd4ht4H1BRM8A5E1x-cBMv4mg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Marc Dionne <marc.c.dionne@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f49.google.com ([209.85.215.49]:36194 "EHLO
	mail-lf0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932802AbcASSLd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2016 13:11:33 -0500
Received: by mail-lf0-f49.google.com with SMTP id h129so149689981lfh.3
        for <netdev@vger.kernel.org>; Tue, 19 Jan 2016 10:11:32 -0800 (PST)
In-Reply-To: <CAB9dFdsVxzi_Tx2yvStXLr2qvqd4ht4H1BRM8A5E1x-cBMv4mg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 19, 2016 at 12:08 PM, Marc Dionne <marc.c.dionne@gmail.com> wrote:
> On Tue, Jan 19, 2016 at 12:31 PM, Craig Gallek <kraig@google.com> wrote:
>>
>> I need to think about how to handle setsockopt-after-bind condition a
>> bit more, but the NULL pointer dereference is obviously wrong.  Do you
>> have a way to easily reproduce this?  I've only managed to get it to
>> happen once so far...
>
> The attached code reliably triggers the crash for me.

I think the patch below will address this issue (sorry in advance if
gmail screws up the whitespace...).  I'll send it for formal review
once I finish testing it.

Craig

diff --git a/net/core/sock_reuseport.c b/net/core/sock_reuseport.c
index 1df98c557440..004cb2c974ac 100644
--- a/net/core/sock_reuseport.c
+++ b/net/core/sock_reuseport.c
@@ -97,6 +97,11 @@ int reuseport_add_sock(struct sock *sk, const
struct sock *sk2)
 {
  struct sock_reuseport *reuse;

+  if (!rcu_access_pointer(sk2->sk_reuseport_cb)) {
+   int err = reuseport_alloc(sk2);
+   if (err) return err;
+  }
+
  spin_lock_bh(&reuseport_lock);
  reuse = rcu_dereference_protected(sk2->sk_reuseport_cb,
   lockdep_is_held(&reuseport_lock)),
