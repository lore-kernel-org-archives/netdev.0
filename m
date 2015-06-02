From: Andy Lutomirski <luto@kernel.org>
Subject: How do I avoid recvmsg races with IP_RECVERR?
Date: Tue, 2 Jun 2015 12:40:33 -0700
Message-ID: <CALCETrW-jkMrEjidwCTraeAaHCHA_+9eExQAz2phvn=OB8RMhQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Network Development <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:54793 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751265AbbFBTk5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Jun 2015 15:40:57 -0400
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id D0D6E204B5
	for <netdev@vger.kernel.org>; Tue,  2 Jun 2015 19:40:56 +0000 (UTC)
Received: from mail-la0-f46.google.com (mail-la0-f46.google.com [209.85.215.46])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id D988320412
	for <netdev@vger.kernel.org>; Tue,  2 Jun 2015 19:40:55 +0000 (UTC)
Received: by labpy14 with SMTP id py14so121968370lab.0
        for <netdev@vger.kernel.org>; Tue, 02 Jun 2015 12:40:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As far as I can tell, enabling IP_RECVERR causes the presence of a
queued error to cause recvmsg, etc to return an error (once).  It's
worse, though: a new error can be queued asynchronously at any time,
this setting sk_err to a nonzero value.  How do I sensibly distinguish
recvmsg failures to to genuine errors receiving messages from recvmsg
failures because there's a queued error?

The only way I can see to get reliable error handling is to literally
call recvmsg in a loop:

while (true /* or while POLLIN is set */) {
  int ret = recvmsg(..., MSG_ERRQUEUE not set);
  if (ret < 0 && /* what goes here? */) {
    whoops!  this might be a harmless asynchronous error!
    take no action!
  }

  /* if POLLERR (or maybe unconditionally), recvmsg(..., MSG_ERRQUEUE);
}

The problem is that, if I'm screwing something up (thus causing EINVAL
or something similar), this will just spin forever.

Am I missing something here?  Would it make sense to add
MSG_IGNORE_ERROR to suppress the sock_error check or IP_RECVERR=2 to
stop setting sk_err?


Thanks,
Andy
