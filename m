From: Willem de Bruijn <willemb@google.com>
Subject: Re: LTP recv/recvmsg tests failing on 3.17
Date: Tue, 23 Sep 2014 10:57:41 -0400
Message-ID: <CA+FuTScNSGYxWtB-D_iL_7TQO=z4r5_29-W8d=VRwh1M6Ym_UQ@mail.gmail.com>
References: <20140923091108.2788de76@as>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>
To: Chuck Ebbert <cebbert.lkml@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f53.google.com ([209.85.216.53]:55372 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756185AbaIWO6O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2014 10:58:14 -0400
Received: by mail-qa0-f53.google.com with SMTP id cm18so1726778qab.12
        for <netdev@vger.kernel.org>; Tue, 23 Sep 2014 07:58:11 -0700 (PDT)
In-Reply-To: <20140923091108.2788de76@as>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 23, 2014 at 10:11 AM, Chuck Ebbert <cebbert.lkml@gmail.com> wrote:
> LTP tests recv01, recvfrom01 and recvmsg01 are reporting failure on
> their "invalid flags" tests on 3.17. They pass a value of -1 for flags
> and expect to get EINVAL back, but now they get EAGAIN.
..
>
> Before this change, the first flag tested was MSG_OOB, which eventually
> causes EINVAL to be returned. Now this flag gets tested first, and
> ip_recv_err() returns EAGAIN.
>
> LTP setting every flag and expecting behavior to remain unchanged is
> probably wrong, but is EAGAIN correct here? I can't find any spec for
> this.

EINVAL does seem a suitable return value for invalid
combinations of flags, if those are explicitly checked. The
stack does not do this, though. Most flags are simply
ignored. For backward compatibility, this leniency is
likely required.

Previously, EINVAL was returned, but not  because msg_flags
contained an unsupported combination. MSG_OOB happened
to be the first tested flag in the set and happens to return
EINVAL when no urgent data is waiting.

I think applications simply cannot assume a consistent
return value when passing unsupported combinations
of flags. This is undefined behavior.
