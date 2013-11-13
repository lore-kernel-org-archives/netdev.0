From: Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: shutdown(3) and bluetooth.
Date: Tue, 12 Nov 2013 19:28:19 -0500
Message-ID: <20131113002819.GB12615@redhat.com>
References: <20131112211125.GA2912@redhat.com>
 <DF4C2B40-BD87-4E88-911D-E3E5F488CAE4@holtmann.org>
 <20131112221038.GA6689@redhat.com>
 <FC5CE013-B077-4EA5-81C1-A7D8B4A5EF85@holtmann.org>
 <20131112224819.GE9057@redhat.com>
 <D8BE686E-E81D-48CD-8D67-2B138191E0CC@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org development"
	<linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <D8BE686E-E81D-48CD-8D67-2B138191E0CC-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 13, 2013 at 08:37:15AM +0900, Marcel Holtmann wrote:
 
 > > So it seems it affects both SCO and RFCOMM.
 > > 
 > >> What kernel did you run this against? It is a shot in the dark, but can you try linux-next quickly.
 > >> There was a socket related fix for the socket options where we confused RFCOMM vs L2CAP struct sock.
 > > 
 > > first noticed it on Linus' latest HEAD, and then reproduced it on 3.11.6
 > > I'll look at linux-next tomorrow.
 > 
 > I looked through the code and only call bt_sock_wait_state when SOCK_LINGER and sk_lingertime is set. In that case we actually block until the socket state changes to BT_CLOSED.
 > 
 > The only way I see this could happen is if you have a huge linger timeout and confused the socket state before. What is actually the list of system calls that you are throwing at this socket.

Ah. I recently changed some code that's now doing this on every socket at shutdown..
(simplified cut-n-paste)

        struct linger ling = { .l_onoff = FALSE, };

        for (i = 0; i < nr_sockets; i++) {
                fd = shm->sockets[i].fd;
                shm->sockets[i].fd = 0;

                setsockopt(fd, SOL_SOCKET, SO_LINGER, &ling, sizeof(struct linger));
                shutdown(fd, SHUT_RDWR);
                close(fd);
        }

I could just rip out that linger code completely and just hope that sockets staying in
TIME_WAIT is good enough. iirc, I added it when after multiple runs, some of the
weirder protocols would fail to open a socket once a certain number of existing
sockets had opened, even if they were in SOCK_WAIT

two remaining questions though. That code is setting linger to false. Why would
that cause the sk_lingertime to be taken into consideration ?  And why is this
only a problem for bluetooth (apparently) ?

	Dave
