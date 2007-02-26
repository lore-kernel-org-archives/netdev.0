From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Subject: Re: [PATCH] fix limited slow start bug
Date: Mon, 26 Feb 2007 00:02:59 -0300
Message-ID: <39e6f6c70702251902g48d445b1o85f0c328c60d32f3@mail.gmail.com>
References: <6.1.1.1.2.20070225095105.049cd960@192.168.6.12>
	 <20070225.154311.71091747.davem@davemloft.net>
	 <39e6f6c70702251819x2698c56et6e996898271a4342@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: simrw@sim-basis.de, netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.226]:44729 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751078AbXBZDDB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Feb 2007 22:03:01 -0500
Received: by wx-out-0506.google.com with SMTP id h31so1217721wxd
        for <netdev@vger.kernel.org>; Sun, 25 Feb 2007 19:03:00 -0800 (PST)
In-Reply-To: <39e6f6c70702251819x2698c56et6e996898271a4342@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/25/07, Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com> wrote:
> On 2/25/07, David Miller <davem@davemloft.net> wrote:
> > From: Roger While <simrw@sim-basis.de>
> > Date: Sun, 25 Feb 2007 09:55:34 +0100
> >
> > > Was anything done about size/member alignment of struct tcp_sock per
> > > mail from last year  -
> > > http://marc.theaimsgroup.com/?l=linux-netdev&m=114318857102290&w=2
> > >
> > > (I have no idea what current size is)
> >
> > Nothing has been done yet but I've been thinking about it a lot
> > over the past year and I've had some discussions with other
> > developers such as Arnaldo.
> >
> > It's just a matter of me being backlogged, so I never get to
> > it as often as I would like :)
>
> Attached goes a current (DaveM's net-2.6 git tree build) pahole
> picture of tcp_sock on UP, 32bits, summary:
>
> }; /* size: 1288, cachelines: 21 */
>    /* last cacheline: 8 bytes */
>
> and for the really curious, take a look at:
>
> http://oops.ghostprotocols.net:81/acme/dwarves/tcp_sock.pahole.expand_types.txt
>
> All the types are expanded, makes a pretty big picture :-)
>

And looking at it I saw I have Ingo's timer debugging option enabled,
which makes struct timer_list a bit bigger:

struct timer_list {
        struct list_head {
                struct list_head * next;           /*     0     4 */
                struct list_head * prev;           /*     4     4 */
        } entry;                                   /*     0     8 */
        long unsigned int expires;                 /*     8     4 */
        void       (*function)(long unsigned int); /*    12     4 */
        long unsigned int data;                    /*    16     4 */
        struct tvec_t_base_s * base;               /*    20     4 */

        void *     start_site;                     /*    24     4 */
        char       start_comm[16];                 /*    28    16 */
        int        start_pid;                      /*    44     4 */
} icsk_delack_timer; /*   668    48 */

The three last members are related to debugging, so discount 24 bytes
times 3, as there are tree struct timer_list inside struct tcp_sock.

- Arnaldo
