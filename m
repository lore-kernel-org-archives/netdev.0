From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH net] bpf: don't zero out the info struct in
 bpf_obj_get_info_by_fd()
Date: Tue, 25 Jul 2017 16:15:47 -0700
Message-ID: <20170725161547.64d1cba5@cakuba.netronome.com>
References: <20170725221612.6937-1-jakub.kicinski@netronome.com>
        <5977CD65.20504@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        alexei.starovoitov@gmail.com, kafai@fb.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:33490 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750897AbdGYXPu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 19:15:50 -0400
Received: by mail-pg0-f42.google.com with SMTP id g14so27268407pgu.0
        for <netdev@vger.kernel.org>; Tue, 25 Jul 2017 16:15:50 -0700 (PDT)
In-Reply-To: <5977CD65.20504@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 26 Jul 2017 00:59:49 +0200, Daniel Borkmann wrote:
> > @@ -418,6 +420,8 @@ static void test_bpf_obj_id(void)
> >   		nr_id_found++;
> >
> >   		err = bpf_obj_get_info_by_fd(prog_fd, &prog_info, &info_len);
> > +		prog_infos[i].jited_prog_insns = 0;
> > +		prog_infos[i].xlated_prog_insns = 0;  
> 
> Can you elaborate why this one above is needed?

Ah, I removed the comment about it at the last minute.  The check below
compares the info we get here with info we got reading the programs in
the earlier loop - using memcmp().  This call, however, doesn't fill in
the pointers for jited and xlated images, so the memcmp() would fail.

It used to work when bpf_obj_get_info_by_fd() was zeroing info, since
the pointers would be cleared by it, and no dump ever returned, it
didn't matter that the call sites differ.

> >   		CHECK(err || info_len != sizeof(struct bpf_prog_info) ||
> >   		      memcmp(&prog_info, &prog_infos[i], info_len),
> >   		      "get-prog-info(next_id->fd)",
