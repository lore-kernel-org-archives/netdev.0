From: Miklos Szeredi <mszeredi@suse.cz>
Subject: Re: Linux Kernel Splice Race Condition with page invalidation
Date: Fri, 29 Aug 2008 11:58:21 +0200
Message-ID: <1220003901.6581.201.camel@tucsk>
References: <200808281649.51440.alexandre.lissy@smartjog.com>
	 <1219937801.6581.183.camel@tucsk>
	 <200808281743.58907.alexandre.lissy@smartjog.com>
	 <1219940127.6581.194.camel@tucsk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Alexandre LISSY <alexandre.lissy@smartjog.com>
To: Eugene Teo <eugeneteo@kernel.sg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:52649 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752986AbYH2J6Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Aug 2008 05:58:25 -0400
In-Reply-To: <1219940127.6581.194.camel@tucsk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I forgot the example programs from the forward, thanks Eugene for the
reminder.

So here they are:

epoll+splice.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
#define _GNU_SOURCE
#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <signal.h>
#include <string.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include <arpa/inet.h>
#include <netinet/in.h>

#include <sys/epoll.h>
#include <sys/socket.h>
#include <sys/types.h>

#define MAX_EVENTS 	32
/* #define BUF_SIZE	1400	// =3D=3D> ~ 25-30% de CPU =C3=A0 4096 clients=
 */
/* #define BUF_SIZE	32768	// =3D=3D> ~ 50% de CPU =C3=A0 4096 clients *=
/
/* #define BUF_SIZE	8192	// =3D=3D> ~ 35% de CPU =C3=A0 4096 clients */
#define BUF_SIZE	131072
#define MAX_CONNEXIONS	16384
#define SERVER_IP	"127.0.0.1"
#define SERVER_PORT	8003

typedef enum {
	INITIAL			=3D 1,
	RECU_REQUETE_CLIENT	=3D 2,
	ATT_REPONSE_SERVEUR	=3D 3
} proxy_status ;

struct proxy
{
	unsigned char type;
	int client_fd;	/* fd connected to client */
	int server_fd;  /* fd connected to server */
	/*=20
	 * 0 : client
	 * 1 : server
	 */
	ssize_t datalen;
	int curpos;
	proxy_status Statut;
	char * buf;
	struct epoll_event * ev;
	struct proxy * peer;
	int * tube;
};

struct poll {
	void * socks_lock;
/*	void * socks; */
	int socket_fd;
	int epoll_fd;
	struct proxy * pr;
};

/* typedef struct proxy epoll_data_t; */

struct poll gpoll;

/* struct proxy Connexions[MAX_CONNEXIONS];
unsigned int curConnexionsPos =3D 0; */

void setnonblocking(int fd)
{
	fcntl(fd, F_SETFL, ( fcntl(fd, F_GETFL) | O_NONBLOCK ));
}

/*
 * Init control.
 * Init epoll.
 * Bind and listen on control port.
 */
void 	poll_init_tcp()
{
    struct sockaddr_in  	saddr;
    struct epoll_event		*event;
    struct proxy		*Proxy;
    int 			i =3D 1;

    /* pthread_mutex_init(&gpoll.socks_lock, NULL);

    gpoll.socks		=3D NULL; */
    /* Init epoll */
    gpoll.epoll_fd 		=3D epoll_create(32);
    gpoll.socket_fd		=3D socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);

    event =3D (struct epoll_event *)malloc(sizeof(struct epoll_event));
    Proxy =3D (struct proxy *)malloc(sizeof(struct proxy));
    if(event =3D=3D NULL || Proxy =3D=3D NULL)
    {
    	perror("malloc()");
	return;
    }
    memset(event, 0, sizeof(struct epoll_event));
    memset(Proxy, 0, sizeof(struct proxy));
    event->events 		=3D EPOLLIN | EPOLLOUT;
    Proxy->client_fd		=3D gpoll.socket_fd;
    Proxy->server_fd		=3D gpoll.socket_fd;
    Proxy->curpos		=3D 0;
    Proxy->ev			=3D event;
    event->data.ptr		=3D Proxy;
    gpoll.pr			=3D Proxy;

    fprintf(stderr, "Stored fd : %d, %d in %p\n", Proxy->client_fd, Pro=
xy->server_fd, Proxy);

    saddr.sin_family		=3D AF_INET;
    saddr.sin_addr.s_addr 	=3D INADDR_ANY;
    saddr.sin_port 		=3D htons(8080);

    if (gpoll.socket_fd =3D=3D -1)
        fprintf(stderr, "back-ch: socket SOCK_STREAM: %s\n", strerror(e=
rrno));

    if (-1 =3D=3D setsockopt(gpoll.socket_fd, SOL_SOCKET, SO_REUSEADDR,=
 &i, sizeof (i)))
        fprintf(stderr, "back-ch: setsockopt SO_REUSEADDR: %s\n", strer=
ror(errno));

    if (-1 =3D=3D bind(gpoll.socket_fd, (struct sockaddr *)&saddr, size=
of (saddr)))
        fprintf(stderr, "back-ch: bind: %s\n", strerror(errno));

    if (-1 =3D=3D listen(gpoll.socket_fd, 10))
        fprintf(stderr, "ctlchannel: listen: %s\n", strerror(errno));

    if (epoll_ctl(gpoll.epoll_fd, EPOLL_CTL_ADD, gpoll.socket_fd, event=
) < 0)
        fprintf(stderr, "cannot control epoll");

    setnonblocking(gpoll.epoll_fd);
}


/*
 * This function accept an incoming connection, add it to epoll, set it=
 to non-blocking mode,=20
 * create a new sock struct, fill it and add it to the internal chained=
 list.
 */
void	accept_sock(void)
{
    int sd, dest;
    int * tube;
    struct sockaddr saddr;
    struct sockaddr_in dest_addr;
    struct proxy * Client, * Serveur;
    char * buffer;
    struct epoll_event * evClient, * evServeur;
    socklen_t saddrlen;
    socklen_t dest_addrlen;

    /* Accept connection */
    saddrlen =3D sizeof(saddr);
    sd =3D accept(gpoll.socket_fd, &saddr, &saddrlen);

    dest_addrlen =3D sizeof(dest_addr);
    dest_addr.sin_family =3D AF_INET;
    dest_addr.sin_port   =3D htons(SERVER_PORT);
    inet_aton(SERVER_IP, &dest_addr.sin_addr);

    dest =3D socket(PF_INET, SOCK_STREAM, 0);=20
    if(dest =3D=3D -1)
    {
	perror("socket()");
	return;
    }

    if( connect(dest, (struct sockaddr *) &dest_addr, dest_addrlen) =3D=
=3D -1 )
    {
	perror("connect()");
	if(shutdown(sd, SHUT_RDWR) =3D=3D -1)
	{
		perror("shutdown()");
	}
	return;
    }

    tube =3D (int *)malloc(sizeof(int)*2);
    Client =3D (struct proxy *)malloc(sizeof(struct proxy));
    Serveur =3D (struct proxy *)malloc(sizeof(struct proxy));
    evClient =3D (struct epoll_event *)malloc(sizeof(struct epoll_event=
));
    evServeur =3D (struct epoll_event *)malloc(sizeof(struct epoll_even=
t));
    buffer =3D (char *)malloc(sizeof(char)*BUF_SIZE);
    if(buffer =3D=3D NULL || tube =3D=3D NULL || Client =3D=3D NULL || =
Serveur =3D=3D NULL || evClient =3D=3D NULL || evServeur =3D=3D NULL)
    {
	perror("malloc()");
	exit(EXIT_FAILURE);
    }

    if(pipe(tube) < 0)
    {
    	perror("pipe()");
	exit(EXIT_FAILURE);
    }

    Client->client_fd	=3D sd;
    Client->server_fd	=3D dest;
    Client->curpos	=3D 0;
    Client->datalen	=3D 16;
    Client->type	=3D 0;
    Client->buf		=3D buffer;
    Client->Statut	=3D 0;
    Client->ev		=3D evClient;
    Client->peer	=3D Serveur;
    Client->tube	=3D tube;
    Serveur->client_fd	=3D sd;
    Serveur->server_fd	=3D dest;
    Serveur->curpos	=3D 0;
    Serveur->datalen	=3D 16;
    Serveur->type	=3D 1;
    Serveur->buf	=3D buffer;
    Serveur->Statut	=3D 0;
    Serveur->ev		=3D evServeur;
    Serveur->peer	=3D Client;
    Serveur->tube	=3D tube;

    memset(evClient, 0, sizeof(struct epoll_event));
    memset(evServeur, 0, sizeof(struct epoll_event));
    evClient->events	=3D EPOLLIN | EPOLLOUT | EPOLLET;
    evClient->data.ptr	=3D Client;
    evServeur->events	=3D EPOLLIN | EPOLLOUT | EPOLLET;
    evServeur->data.ptr	=3D Serveur;


    if (epoll_ctl(gpoll.epoll_fd, EPOLL_CTL_ADD, sd, evClient))
        fprintf(stderr, "problem with client socket");

    if (epoll_ctl(gpoll.epoll_fd, EPOLL_CTL_ADD, dest, evServeur))
        fprintf(stderr, "problem with server socket");

    setnonblocking(dest);
    setnonblocking(sd);

#ifdef VERBOSE
    fprintf(stderr, "accept() on fd %d\n", sd);
    fprintf(stderr, "connect() on fd %d\n", dest);
#endif
}

void close_socket(struct proxy * p, unsigned char peer)
{
	int cfd, sfd, result;

	cfd =3D p->client_fd;
	sfd =3D p->server_fd;

	if (epoll_ctl(gpoll.epoll_fd, EPOLL_CTL_DEL, cfd, NULL))
		perror("epoll_ctl()");
	if (epoll_ctl(gpoll.epoll_fd, EPOLL_CTL_DEL, sfd, NULL))
		perror("epoll_ctl()");

	if(p->type =3D=3D 0)
	{
#ifdef VERBOSE
		fprintf(stderr, "Freeing buffer @ %p\n", p->buf);
#endif
		free(p->buf);

#ifdef VERBOSE
		fprintf(stderr, "Freeing pipe @ %p\n", p->tube);
#endif
		close(p->tube[0]);
		close(p->tube[1]);
		free(p->tube);
	}
#ifdef VERBOSE
	fprintf(stderr, "Freeing struct epoll_event @ %p\n", p->ev);
#endif
	free(p->ev);
	if(peer =3D=3D 1)
	{
#ifdef VERBOSE
		fprintf(stderr, "Freeing peer's struct proxy @ %p\n", p->peer);
#endif
		close_socket(p->peer, 0);
	}
#ifdef VERBOSE
	fprintf(stderr, "Freeing struct proxy @ %p\n", p);
#endif
	free(p);

#ifdef VERBOSE
	fprintf(stderr, "Shutting down fds (%d, %d)\n", sfd, cfd);
#endif
	result =3D shutdown(sfd, SHUT_RDWR);
	if(result =3D=3D -1)
		perror("shutdown()");

	result =3D shutdown(cfd, SHUT_RDWR);
	if(result =3D=3D -1)
		perror("shutdown()");
}

void	poll_loop()
{
    struct epoll_event 	events[MAX_EVENTS];
    int n =3D 0, repfd =3D 0, fd =3D 0;
    long read_incoming, write_incoming, write_outcoming;
    struct proxy * p;
    unsigned char type;

    memset(events, 0, sizeof(struct epoll_event)*MAX_EVENTS);

    for(;;)=20
    {
        int nfds =3D epoll_wait(gpoll.epoll_fd, events, MAX_EVENTS, -1)=
;
        for (n =3D 0; n < nfds; ++n)=20
        {
#ifdef DEBUG
	    fprintf(stderr, "(EPOLLIN=3D%d, EPOLLOUT=3D%d, EPOLLRDHUP=3D%d, EP=
OLLPRI=3D%d, EPOLLERR=3D%d, EPOLLHUP=3D%d)\n",
	    	events[n].events & EPOLLIN,
	    	events[n].events & EPOLLOUT,
	    	events[n].events & EPOLLRDHUP,
	    	events[n].events & EPOLLPRI,
	    	events[n].events & EPOLLERR,
	    	events[n].events & EPOLLHUP
		);

		fprintf(stderr, "Retrieving user data from %p\n", events[n].data.ptr)=
;
#endif

		p =3D events[n].data.ptr;
		if (events[n].events & EPOLLIN)
		{
			if (p->server_fd =3D=3D gpoll.socket_fd && (int)p->client_fd =3D=3D =
gpoll.socket_fd)
				accept_sock();
		}

		type	=3D p->type;
		/**
		 * Type :
		 * 	0 =3D> Client
		 * 	1 =3D> Serveur
		 **/
		switch(type)
		{
			case 0:	fd	=3D p->client_fd;
				repfd	=3D p->server_fd;
				break;
			case 1:	fd	=3D p->server_fd;
				repfd	=3D p->client_fd;
				break;
		}

		if (events[n].events & EPOLLHUP || events[n].events & EPOLLRDHUP)
		{
			/* Suppression des FDs concernant les sockets morts pour epoll. */
			close_socket(p, 1);
			continue;
		}

            if (events[n].events & EPOLLIN)
            {
#ifdef DEBUG
		fprintf(stderr, "fd %d is ready for reading !\n", fd);
#endif
		if(p->buf !=3D NULL)
		{
			read_incoming =3D splice(fd, NULL, p->tube[1], NULL, 1400, SPLICE_F_=
NONBLOCK | SPLICE_F_MORE | SPLICE_F_MOVE);
			if(read_incoming < 0)
			{
				if(errno =3D=3D EAGAIN)
				{
					fprintf(stderr, "EAGAIN: IN=3D%d, OUT=3D%d\n", fd, p->tube[1]);
					continue;
				}
				perror("splice()");
#ifdef DEBUG
				fprintf(stderr, "Was: %ld =3D splice(%d, %p, %d, %p, %d, %d);\n",
					read_incoming,
					fd,
					NULL,
					p->tube[1],
					NULL,
					12*1024,
					SPLICE_F_NONBLOCK
				);
#endif
				break;
			} else {
				if(read_incoming =3D=3D 0)
				{
					fprintf(stderr, "Something's wrong. Closing this proxy.\n");
					close_socket(p, 1);
					continue;
				}

#ifdef DEBUG
				fprintf(stderr, "Splice()'d %lu bytes from %d to %d\n", read_incomi=
ng, fd, p->tube[1]);
#endif
				write_outcoming =3D read_incoming;
				while(write_outcoming > 0)
				{
			=09
					write_incoming =3D splice(p->tube[0], NULL, repfd, NULL, write_out=
coming, SPLICE_F_NONBLOCK | SPLICE_F_MORE | SPLICE_F_MOVE);
					if(write_incoming < 0)
					{
						if(write_incoming =3D=3D -EAGAIN)
						{
							fprintf(stderr, "EAGAIN: IN=3D%d, OUT=3D%d\n", p->tube[0], repfd=
);
							continue;
						}

						perror("splice()");
						break;
					}
			=09
					write_outcoming -=3D write_incoming;
#ifdef DEBUG
					fprintf(stderr, "Splice()'d %lu bytes from %d to %d\n", write_inco=
ming, p->tube[0], repfd);
#endif
#ifdef DEBUG
					fprintf(stderr, "Splice()'d %lu bytes from %d to %d (via %d, %d). =
Still %lu bytes to send.\n", write_incoming, fd, repfd, p->tube[0], p->=
tube[1], write_outcoming);
#endif
				}

				switch(type)
				{
					case 0: /* Socket client pr=C3=AAt en lecture */
						break;

					case 1: /* Socket serveur pr=C3=AAt en lecture */
						break;
				}
			}
		}
            }
	}
    }
}

void handler(int signo)
{
	if(signo =3D=3D SIGTERM || signo =3D=3D SIGINT)
	{
		fprintf(stderr, "Got SIGTERM or SIGINT, cleaning up things ...\n");
		epoll_ctl(gpoll.epoll_fd, EPOLL_CTL_DEL, gpoll.socket_fd, NULL);
		shutdown(gpoll.socket_fd, SHUT_RDWR);
		free(gpoll.pr->buf);
		free(gpoll.pr->ev);
		free(gpoll.pr);
		exit(EXIT_SUCCESS);
	} else {
		fprintf(stderr, "UNKNOWN SIGNAL !!! : %d\n", signo);
	}
}

int main(int argc, char ** argv)
{
	signal(SIGTERM, handler);
	signal(SIGINT, handler);
	poll_init_tcp();
	poll_loop();

	return EXIT_SUCCESS;
}
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D


=EF=BB=BFepoll.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=EF=BB=BF#include <errno.h>
#include <fcntl.h>
#include <signal.h>
#include <string.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include <arpa/inet.h>
#include <netinet/in.h>

#include <sys/epoll.h>
#include <sys/socket.h>
#include <sys/types.h>

#define MAX_EVENTS 	2
/* #define BUF_SIZE	1400	// =3D=3D> ~ 25-30% de CPU =C3=A0 4096 clients=
 */
/* #define BUF_SIZE	32768	// =3D=3D> ~ 50% de CPU =C3=A0 4096 clients *=
/
#define BUF_SIZE	1400	// =3D=3D> ~ 35% de CPU =C3=A0 4096 clients
#define MAX_CONNEXIONS	16384
#define SERVER_IP	"127.0.0.1"
#define SERVER_PORT	8003

typedef enum {
	INITIAL			=3D 1,
	RECU_REQUETE_CLIENT	=3D 2,
	ATT_REPONSE_SERVEUR	=3D 3
} proxy_status ;

struct proxy
{
	unsigned char type;
	int client_fd;	/* fd connected to client */
	int server_fd;  /* fd connected to server */
	/*=20
	 * 0 : client
	 * 1 : server
	 */
	ssize_t datalen;
	int curpos;
	proxy_status Statut;
	char * buf;
	struct epoll_event * ev;
	struct proxy * peer;
};

struct poll {
	void * socks_lock;
/*	void * socks; */
	int socket_fd;
	int epoll_fd;
	struct proxy * pr;
};

/* typedef struct proxy epoll_data_t; */

struct poll gpoll;

/* struct proxy Connexions[MAX_CONNEXIONS];
unsigned int curConnexionsPos =3D 0; */

void setnonblocking(int fd)
{
	fcntl(fd, F_SETFL, ( fcntl(fd, F_GETFL) | O_NONBLOCK ));
}

/**
 * Recherche du FD de l'autre entit=C3=A9.
 *
 * type :
 * 	0 =3D> client
 * 	1 =3D> serveur
int find_peer(int fd, struct proxy ** target, unsigned char * type)
{
	int i, found_fd;
	struct proxy *p;

	fprintf(stderr, "Looking for fd %d\n", fd);
	for(i =3D 0; i < curConnexionsPos; i++)
	{
		p =3D &Connexions[i];
		fprintf(stderr, "p->client_fd=3D%d\np->server_fd=3D%d\n\n", p->client=
_fd, p->server_fd);

		if(p->client_fd =3D=3D fd)
		{
			found_fd =3D p->server_fd;
			*type	 =3D 0;
		}
		else if(p->server_fd =3D=3D fd)
		{
			found_fd =3D p->client_fd;
			*type    =3D 1;
		}

		*target =3D p;
		fprintf(stderr, "Found at p=3D%p\n", p);

		return found_fd;
	}

	errno =3D EBADF;
	return -1;
}
*/

/*
 * Init control.
 * Init epoll.
 * Bind and listen on control port.
 */
void 	poll_init_tcp()
{
    struct sockaddr_in  	saddr;
    struct epoll_event		*event;
    struct proxy		*Proxy;
    int 			i =3D 1;

    /* pthread_mutex_init(&gpoll.socks_lock, NULL);

    gpoll.socks		=3D NULL; */
    /* Init epoll */
    gpoll.epoll_fd 		=3D epoll_create(2);
    gpoll.socket_fd		=3D socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);

    event =3D (struct epoll_event *)malloc(sizeof(struct epoll_event));
    Proxy =3D (struct proxy *)malloc(sizeof(struct proxy));
    if(event =3D=3D NULL || Proxy =3D=3D NULL)
    {
    	perror("malloc()");
	return;
    }
    memset(event, 0, sizeof(struct epoll_event));
    memset(Proxy, 0, sizeof(struct proxy));
    event->events 		=3D EPOLLIN | EPOLLOUT;
    Proxy->client_fd		=3D gpoll.socket_fd;
    Proxy->server_fd		=3D gpoll.socket_fd;
    Proxy->curpos		=3D 0;
    Proxy->ev			=3D event;
    event->data.ptr		=3D Proxy;
    gpoll.pr			=3D Proxy;

    fprintf(stderr, "Stored fd : %d, %d in %p\n", Proxy->client_fd, Pro=
xy->server_fd, Proxy);

    saddr.sin_family		=3D AF_INET;
    saddr.sin_addr.s_addr 	=3D INADDR_ANY;
    saddr.sin_port 		=3D htons(8080);

    if (gpoll.socket_fd =3D=3D -1)
        fprintf(stderr, "back-ch: socket SOCK_STREAM: %s\n", strerror(e=
rrno));

    if (-1 =3D=3D setsockopt(gpoll.socket_fd, SOL_SOCKET, SO_REUSEADDR,=
 &i, sizeof (i)))
        fprintf(stderr, "back-ch: setsockopt SO_REUSEADDR: %s\n", strer=
ror(errno));

    if (-1 =3D=3D bind(gpoll.socket_fd, (struct sockaddr *)&saddr, size=
of (saddr)))
        fprintf(stderr, "back-ch: bind: %s\n", strerror(errno));

    if (-1 =3D=3D listen(gpoll.socket_fd, 10))
        fprintf(stderr, "ctlchannel: listen: %s\n", strerror(errno));

    if (epoll_ctl(gpoll.epoll_fd, EPOLL_CTL_ADD, gpoll.socket_fd, event=
) < 0)
        fprintf(stderr, "cannot control epoll");

    setnonblocking(gpoll.epoll_fd);
}


/*
 * This function accept an incoming connection, add it to epoll, set it=
 to non-blocking mode,=20
 * create a new sock struct, fill it and add it to the internal chained=
 list.
 */
void	accept_sock(void)
{
    int sd, dest;
    struct sockaddr saddr;
    struct sockaddr_in dest_addr;
    struct proxy * Client, * Serveur;
    char * buffer;
    struct epoll_event * evClient, * evServeur;
    socklen_t saddrlen;
    socklen_t dest_addrlen;

    /* Accept connection */
    saddrlen =3D sizeof(saddr);
    sd =3D accept(gpoll.socket_fd, &saddr, &saddrlen);

    dest_addrlen =3D sizeof(dest_addr);
    dest_addr.sin_family =3D AF_INET;
    dest_addr.sin_port   =3D htons(SERVER_PORT);
    inet_aton(SERVER_IP, &dest_addr.sin_addr);

    dest =3D socket(PF_INET, SOCK_STREAM, 0);=20
    if(dest =3D=3D -1)
    {
	perror("socket()");
	return;
    }

    if( connect(dest, (struct sockaddr *) &dest_addr, dest_addrlen) =3D=
=3D -1 )
    {
	perror("connect()");
	if(shutdown(sd, SHUT_RDWR) =3D=3D -1)
	{
		perror("shutdown()");
	}
	return;
    }

    Client =3D (struct proxy *)malloc(sizeof(struct proxy));
    Serveur =3D (struct proxy *)malloc(sizeof(struct proxy));
    evClient =3D (struct epoll_event *)malloc(sizeof(struct epoll_event=
));
    evServeur =3D (struct epoll_event *)malloc(sizeof(struct epoll_even=
t));
    buffer =3D (char *)malloc(sizeof(char)*BUF_SIZE);
    if(buffer =3D=3D NULL || Client =3D=3D NULL || Serveur =3D=3D NULL =
|| evClient =3D=3D NULL || evServeur =3D=3D NULL)
    {
	perror("malloc()");
	exit(EXIT_FAILURE);
    }

    Client->client_fd	=3D sd;
    Client->server_fd	=3D dest;
    Client->curpos	=3D 0;
    Client->datalen	=3D 16;
    Client->type	=3D 0;
    Client->buf		=3D buffer;
    Client->Statut	=3D 0;
    Client->ev		=3D evClient;
    Client->peer	=3D Serveur;
    Serveur->client_fd	=3D sd;
    Serveur->server_fd	=3D dest;
    Serveur->curpos	=3D 0;
    Serveur->datalen	=3D 16;
    Serveur->type	=3D 1;
    Serveur->buf	=3D buffer;
    Serveur->Statut	=3D 0;
    Serveur->ev		=3D evServeur;
    Serveur->peer	=3D Client;

    memset(evClient, 0, sizeof(struct epoll_event));
    memset(evServeur, 0, sizeof(struct epoll_event));
    evClient->events	=3D EPOLLIN | EPOLLOUT | EPOLLET;
    evClient->data.ptr	=3D Client;
    evServeur->events	=3D EPOLLIN | EPOLLOUT | EPOLLET;
    evServeur->data.ptr	=3D Serveur;


    if (epoll_ctl(gpoll.epoll_fd, EPOLL_CTL_ADD, sd, evClient))
        fprintf(stderr, "problem with client socket");

    if (epoll_ctl(gpoll.epoll_fd, EPOLL_CTL_ADD, dest, evServeur))
        fprintf(stderr, "problem with server socket");

    setnonblocking(dest);
    setnonblocking(sd);

#ifdef VERBOSE
    fprintf(stderr, "accept() on fd %d\n", sd);
    fprintf(stderr, "connect() on fd %d\n", dest);
#endif
}

void close_socket(struct proxy * p, unsigned char peer)
{
	int cfd, sfd, result;

	cfd =3D p->client_fd;
	sfd =3D p->server_fd;

	if (epoll_ctl(gpoll.epoll_fd, EPOLL_CTL_DEL, cfd, NULL))
		perror("epoll_ctl()");
	if (epoll_ctl(gpoll.epoll_fd, EPOLL_CTL_DEL, sfd, NULL))
		perror("epoll_ctl()");

	if(p->type =3D=3D 0)
	{
#ifdef VERBOSE
		fprintf(stderr, "Freeing buffer @ %p\n", p->buf);
#endif
		free(p->buf);
	}
#ifdef VERBOSE
	fprintf(stderr, "Freeing struct epoll_event @ %p\n", p->ev);
#endif
	free(p->ev);
	if(peer =3D=3D 1)
	{
#ifdef VERBOSE
		fprintf(stderr, "Freeing peer's struct proxy @ %p\n", p->peer);
#endif
		close_socket(p->peer, 0);
	}
#ifdef VERBOSE
	fprintf(stderr, "Freeing struct proxy @ %p\n", p);
#endif
	free(p);

#ifdef VERBOSE
	fprintf(stderr, "Shutting down fds (%d, %d)\n", sfd, cfd);
#endif
	result =3D shutdown(sfd, SHUT_RDWR);
	if(result =3D=3D -1)
		perror("shutdown()");

	result =3D shutdown(cfd, SHUT_RDWR);
	if(result =3D=3D -1)
		perror("shutdown()");
}

void	poll_loop()
{
    struct epoll_event 	events[MAX_EVENTS];
    int n =3D 0, repfd =3D 0, fd =3D 0;
    ssize_t read_incoming, write_outcoming, copied;
    struct proxy * p;
    unsigned char type;

    memset(events, 0, sizeof(struct epoll_event)*MAX_EVENTS);

    for(;;)=20
    {
        int nfds =3D epoll_wait(gpoll.epoll_fd, events, MAX_EVENTS, -1)=
;
        for (n =3D 0; n < nfds; ++n)=20
        {
#ifdef DEBUG
	    fprintf(stderr, "(EPOLLIN=3D%d, EPOLLOUT=3D%d, EPOLLRDHUP=3D%d, EP=
OLLPRI=3D%d, EPOLLERR=3D%d, EPOLLHUP=3D%d)\n",
	    	events[n].events & EPOLLIN,
	    	events[n].events & EPOLLOUT,
	    	events[n].events & EPOLLRDHUP,
	    	events[n].events & EPOLLPRI,
	    	events[n].events & EPOLLERR,
	    	events[n].events & EPOLLHUP
		);

		fprintf(stderr, "Retrieving user data from %p\n", events[n].data.ptr)=
;
#endif

		p =3D events[n].data.ptr;
		if (events[n].events & EPOLLIN)
		{
			if (p->server_fd =3D=3D gpoll.socket_fd && (int)p->client_fd =3D=3D =
gpoll.socket_fd)
				accept_sock();
		}

		type	=3D p->type;
		/**
		 * Type :
		 * 	0 =3D> Client
		 * 	1 =3D> Serveur
		 **/
		switch(type)
		{
			case 0:	fd	=3D p->client_fd;
				repfd	=3D p->server_fd;
				break;
			case 1:	fd	=3D p->server_fd;
				repfd	=3D p->client_fd;
				break;
		}

		if (events[n].events & EPOLLHUP)
		{
			/* Suppression des FDs concernant les sockets morts pour epoll. */
			close_socket(p, 1);
			continue;
		}

            if (events[n].events & EPOLLIN)
            {
#ifdef DEBUG
		fprintf(stderr, "fd %d is ready for reading into %p.\n", fd, p->buf);
#endif
		if(p->buf !=3D NULL)
		{
			read_incoming =3D read(fd, p->buf, BUF_SIZE);
			p->datalen =3D read_incoming;

#ifdef DEBUG
			fprintf(stderr, "Read %d bytes from %d.\n", read_incoming, fd);
#endif

			if(read_incoming =3D=3D 0)
			{
				fprintf(stderr, "Something's wrong on fd %d : I got no data.\n", fd=
);
				/* close_socket(p, 1); */
				continue;
			}

			copied =3D write(repfd, p->buf, p->datalen);
			p->datalen -=3D copied;

			switch(type)
			{
				case 0: /* Socket client pr=C3=AAt en lecture */
					break;

				case 1: /* Socket serveur pr=C3=AAt en lecture */
					break;
			}
		}
            }
/*
            else if (events[n].events & EPOLLOUT)
            {
#ifdef DEBUG
		fprintf(stderr, "fd %d is ready for writing. ", fd);
#endif
		if(p !=3D NULL && p->buf !=3D NULL && p->datalen > 0)
		{
			write_outcoming =3D write(fd, p->buf, p->datalen);
			p->datalen -=3D write_outcoming;
#ifdef DEBUG
			fprintf(stderr, "Write %d bytes to %d.\n", write_outcoming, fd);
#endif
			switch(type)
			{
				case 0: // Socket client pr=C3=AAt en =C3=A9criture
					break;

				case 1: // Socket serveur pr=C3=AAt en =C3=A9criture
					break;
			}
		}
            }
*/
	}
    }
}

void handler(int signo)
{
	if(signo =3D=3D SIGTERM || signo =3D=3D SIGINT)
	{
		fprintf(stderr, "Got SIGTERM or SIGINT, cleaning up things ...\n");
		epoll_ctl(gpoll.epoll_fd, EPOLL_CTL_DEL, gpoll.socket_fd, NULL);
		shutdown(gpoll.socket_fd, SHUT_RDWR);
		free(gpoll.pr->buf);
		free(gpoll.pr->ev);
		free(gpoll.pr);
		exit(EXIT_SUCCESS);
	} else {
		fprintf(stderr, "UNKNOWN SIGNAL !!! : %d\n", signo);
	}
}

int main(int argc, char ** argv)
{
	signal(SIGTERM, handler);
	signal(SIGINT, handler);
	poll_init_tcp();
	poll_loop();

	return EXIT_SUCCESS;
}
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D



On Thu, 2008-08-28 at 18:15 +0200, Miklos Szeredi wrote:
> Thanks, forwarding to mailing lists.
>=20
> Since you are in a better position to test (already have the
> installation and configuration set up) I'm not going to try to reprod=
uce
> this until you tried 2.6.26.
>=20
> Thanks,
> Miklos
>=20
> On Thu, 2008-08-28 at 17:43 +0200, Alexandre LISSY wrote:
> > Le Thursday 28 August 2008 17:36:41, vous avez =C3=A9crit :
> > > Hi Alexandre,
> > >
> > > On Thu, 2008-08-28 at 16:49 +0200, Alexandre LISSY wrote:
> > > > I saw your mail on LKML, and I feel like I'm experiencing the i=
ssue.
> > > > I'm using a 2.6.25-2-amd64 (from Debian), on two machines, one =
with 32
> > > > bits user land, and the other with 64 bits userland. I also tri=
ed with
> > > > 2.6.25-2-686.
> > >
> > > Thanks for the report.  Usually it's best to send such a report n=
ot just
> > > to an individual developer, but to relevant mailing lists as well=
 (in
> > > this case <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org=
>).
> > > Would you mind if I forwarded your mail to these lists?
> > No problem, I wasn't sure this was the good audience.
> >=20
> > >
> > > > I'm trying to achieve a really fast tcp proxy, mostly for testi=
ng
> > > > purpose. Attached is my code, so you can check, and maybe repro=
duce :)
> > >
> > > Thanks.  I don't know how I can use these programs to reproduce t=
he
> > > problem.  Can you please describe in detail how to set up and run=
 the
> > > test environment?
> > Just compile my code, install a icecast that provide a 128k mp3 str=
eam.
> > Pay attention, the addresses are hardcoded in source, so you need t=
o recompile=20
> > for any change.
> >=20
> > Then, launch many wget or any other tool capable of parallel downlo=
ad, to=20
> > stress the proxy.
> >=20
> > >
> > > > If I use the local icecast (the one on 127.0.0.1), then, I can =
reach
> > > > 62Mbits, if kernel didn't trashed in the middle of the operatio=
n (confere
> > > > "Kernel having fun"), leaving my process unkillable. Need to re=
boot :/.
> > >
> > > This is because of the kernel BUG that you've reported below.  I =
found
> > > this similar report:
> > Yeah, I figured that's linked :)
> >=20
> > >
> > >   http://article.gmane.org/gmane.linux.network/94988
> > >
> > > This may have been fixed in linux-2.6.26.  Could you try a 2.6.26
> > > kernel, to see if you can still reproduce the problem?
> > I'll grab a 2.6.26 from unstable tomorrow and check if it continues=
 to=20
> > happens.
> >=20
> > Thanks for your help :)
> >=20
> > >
> > > Thanks,
> > > Miklos
> > >
> > > > And while it's not trashed, I get many "splice(): Resource temp=
orarily
> > > > unavailable", that don't come up when using a remote icecast.
> > > >
> > > > So, as the only difference is local/remote, I think that latenc=
y matters,
> > > > and considering your message about a race condition, I'm wonder=
ing ...
> > > >
> > > > Thanks for any help/hint !
> > > >
> > > > ---Kernel having fun---
> > > > [65611.886737] BUG: unable to handle kernel NULL pointer derefe=
rence at
> > > > 0000000000000008
> > > > [65611.886737] IP: [<ffffffff803db40d>] tcp_read_sock+0xec/0x1a=
3
> > > > [65611.886737] PGD 1fc64067 PUD 2f2a7067 PMD 0
> > > > [65611.886737] Oops: 0002 [1] SMP
> > > > [65611.886737] CPU 1
> > > > [65611.886737] Modules linked in: ipv6 bonding dm_snapshot dm_m=
irror
> > > > dm_mod loop iTCO_wdt ses i5000_edac pcspkr psmouse evdev dcdbas=
 rng_core
> > > > button edac_core ixgbe shpchp pci_hotplug serio_raw enclosure e=
xt3 jbd
> > > > mbcache raid1 md_mod ide_generic ide_cd_mod cdrom ata_generic l=
ibata dock
> > > > sd_mod piix ide_core ehci_hcd uhci_hcd megaraid_sas bnx2 firmwa=
re_class
> > > > scsi_mod thermal processor fan
> > > > [65611.886737] Pid: 18679, comm: epoll+splice+st Not tainted
> > > > 2.6.25-2-amd64 #1 [65611.886737] RIP: 0010:[<ffffffff803db40d>]=
=20
> > > > [<ffffffff803db40d>] tcp_read_sock+0xec/0x1a3
> > > > [65611.886737] RSP: 0018:ffff81006db59e68  EFLAGS: 00010202
> > > > [65611.886737] RAX: 0000000000000000 RBX: ffff810073c504a0 RCX:
> > > > 0000000000000000
> > > > [65611.886737] RDX: 0000000000000000 RSI: 0000000000000000 RDI:
> > > > ffff810073c504a0
> > > > [65611.886737] RBP: 0000000000000578 R08: ffff81006d5a2080 R09:
> > > > 0000000000000000
> > > > [65611.886737] R10: ffff810065663980 R11: ffffffff802f0637 R12:
> > > > 0000000000000578
> > > > [65611.886737] R13: ffff81006d5a2080 R14: 000000001e5b23ed R15:
> > > > ffff81006d5a2130
> > > > [65611.886737] FS:  0000000000be2850(0063) GS:ffff81007f76db40(=
0000)
> > > > knlGS:0000000000000000
> > > > [65611.886737] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003=
b
> > > > [65611.886737] CR2: 0000000000000008 CR3: 0000000061b55000 CR4:
> > > > 00000000000006e0
> > > > [65611.886737] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
> > > > 0000000000000000
> > > > [65611.886737] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
> > > > 0000000000000400
> > > > [65611.886737] Process epoll+splice+st (pid: 18679, threadinfo
> > > > ffff81006db58000, task ffff81007ee45180)
> > > > [65611.886737] Stack:  ffffffff803db596 ffff81006db59eb8 000005=
782628a210
> > > > ffff81006d5a2080
> > > > [65611.886737]  0000000000000000 0000000000000000 0000000000000=
007
> > > > 0000000000000000
> > > > [65611.886737]  0000000000000578 ffffffff803dbb14 0000000000000=
000
> > > > 0000000000000000
> > > > [65611.886737] Call Trace:
> > > > [65611.886737]  [<ffffffff803db596>] ? tcp_splice_data_recv+0x0=
/0x1c
> > > > [65611.886737]  [<ffffffff803dbb14>] ? tcp_splice_read+0x82/0x1=
ce
> > > > [65611.886737]  [<ffffffff802b7962>] ? sys_splice+0x1b0/0x23e
> > > > [65611.886737]  [<ffffffff8020bd9a>] ? system_call_after_swapgs=
+0x8a/0x8f
> > > > [65611.886737]
> > > > [65611.886737]
> > > > [65611.886737] Code: 00 00 00 f6 44 10 0d 01 0f 85 67 ff ff ff =
41 ff 4f
> > > > 10 48 89 df 48 8b 43 08 48 8b 13 48 c7 43 08 00 00 00 00 48 c7 =
03 00 00
> > > > 00 00 <48> 89 42 08 48 89 10 e8 ab 1b fd ff 48 8b 44 24 08 48 8=
3 78 08
> > > > [65611.886737] RIP  [<ffffffff803db40d>] tcp_read_sock+0xec/0x1=
a3
> > > > [65611.886737]  RSP <ffff81006db59e68>
> > > > [65611.886737] CR2: 0000000000000008
> > > > [65611.886774] ---[ end trace 8f47273d77faf3c8 ]---
> > > > ---Kernel having fun---
> >=20
> >=20
>=20

