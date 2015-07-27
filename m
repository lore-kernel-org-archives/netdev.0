From: Cong Wang <cwang@twopensource.com>
Subject: Re: netns refcnt leak for kernel accept sock
Date: Mon, 27 Jul 2015 11:13:03 -0700
Message-ID: <CAHA+R7Pe08rfERd1rMR1Y_kK2iUm4TDc92rRhhJhr-e+_fsioA@mail.gmail.com>
References: <20150727142146.GC16447@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f175.google.com ([209.85.160.175]:34378 "EHLO
	mail-yk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751353AbbG0SNE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 14:13:04 -0400
Received: by ykax123 with SMTP id x123so76095089yka.1
        for <netdev@vger.kernel.org>; Mon, 27 Jul 2015 11:13:03 -0700 (PDT)
In-Reply-To: <20150727142146.GC16447@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 27, 2015 at 7:21 AM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
>
> I'm running into a netns refcnt issue, and I suspect that
> eeb1bd5c has something to do with it (perhaps we need an
> additional change in sk_clone_lock() after eeb1bd5c).
> Here's the problem:
>
> When we create an syn_recv sock based on a kernel listen sock, we
> take a get_net() ref  with a stack similar to the one shown below.
> Note that the parent (kernel, listen) sock itself has not taken
> a get_net() ref, because it explicitly calls sock_create_kern().
>
>   get_net /* for the newsk */
>   sk_clone_lock
>   inet_csk_clone_lock
>   tcp_create_openreq_child
>   tcp_v4_syn_recv_sock
>   tcp_check_req
>   tcp_v4_do_rcv
>   tcp_v4_rcv
>    :
>
> But it's not clear to me where this refcnt will be released:
> in my case, I expect to create/cleanup kernel sockets as part
> of ->init/->exit for my module, but because the accept socket
> has a netns refcnt, it blocks cleanup_net(), thus my ->exit
> pernet_subsys op cannot run and clean this up, and we have a leak.


That refcnt should be released in sock destructor too, when the tcp
connection is terminated.

>
> I think that sk_clone_lock() should only do a get_net() if the parent
> is not a kernel socket (making this similar to sk_alloc()), i.e.,
>

Given the fact that sk_destruct() checks for sk_net_refcnt, your
patch makes sense to me. But I am not sure how a TCP kernel
socket is supposed to use.
