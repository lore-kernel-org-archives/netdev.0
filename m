From: Yi Li <lovelylich@gmail.com>
Subject: [TCP] Flags returned by poll on connection request to closed peer?
Date: Fri, 23 Nov 2012 18:07:19 +0800
Message-ID: <50AF4AD7.60100@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:45009 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161050Ab2KWKHW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Nov 2012 05:07:22 -0500
Received: by mail-pa0-f46.google.com with SMTP id bh2so3444651pad.19
        for <netdev@vger.kernel.org>; Fri, 23 Nov 2012 02:07:22 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi List,
When I issues a non-blocking connection request to a closed peer, and 
call select() to get the status
of the socket. But When I issues many threads, and I got the statistic 
as follow:

  POLLIN_SET POLLOUT_SET	9980000
  !POLLIN_SET !POLLOUT_SET	0
  POLLIN_SET !POLLOUT_SET0
  !POLLIN_SET POLLOUT_SET20000

as POLLIN_SET&& POLLOUT_SET means connection error.(of course, we are attempting to connect
to a closed peer). But what the meaning of !POLLIN_SET POLLOUT_SET ?

Here is my test program, and my test command is :
./client -d $SERVERS -s $max_range_start -e $max_range_end -t 20000

#include <sys/types.h>
#include <sys/socket.h>
#include <sys/select.h>
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <string.h>
#include <pthread.h>
#include <stdlib.h>
#include <arpa/inet.h>
#include <netdb.h>

#define BUFSIZE 255
#define POOL_SIZE 1000

unsigned short port_start, port_end;
uint32_t server_ip;
int total_count;
unsigned short port_pool[POOL_SIZE];

void usage(const char *name){
     printf("%s: -d SERVER_IP -s SERVER_PORT_S -e SERVER_PORT_E  -t TOTAL_COUNT -h\n", name);
     printf("-d SERVER_IP: server ip is SERVER_IP\n");
     printf("-s SERVER_PORT_S: closed server port range start, one thread per port\n");
     printf("-s SERVER_PORT_E: closed server port range end, one thread per port\n");
     printf("-t TOTAL_COUNT: per thread try TOTAL_COUNT tmies connection requests\n");
     printf("-h: print this help message\n");
     return;
}

void* talk_to_server(void* arg){
     int sockfd, flags, ret, i = 0;
     struct timeval timeout;
     fd_set rset, wset;
     struct sockaddr_in server_addr;
     int index = *((int *)&arg);
	
     server_addr.sin_family = AF_INET;
     server_addr.sin_addr.s_addr = server_ip;
     server_addr.sin_port = htons(port_pool[index]);

     while(i++ < total_count){
	if ((sockfd = socket(AF_INET, SOCK_STREAM, 0)) < 0){
	    perror("client: socket create error");
	    goto exit;
	}

	FD_ZERO(&rset);
	FD_SET(sockfd, &rset);
	wset = rset;
	timeout.tv_sec = 10;
	timeout.tv_usec = 0;
     
	flags = fcntl(sockfd, F_GETFL, 0);
	fcntl(sockfd, F_SETFL, flags | O_NONBLOCK);
     
	if ((ret = connect(sockfd, (struct sockaddr *)&server_addr, sizeof(server_addr))) <= 0){
	    if(ret == 0){
		fprintf(stderr, "client: connect established.\n");
		goto sockfd_exit;
	    }
	    if(errno != EINPROGRESS){
		perror("client: connect failed.");
		goto sockfd_exit;
	    }
	}
     
	if( (ret = select(sockfd+1, &rset, &wset, NULL, &timeout)) < 0){
	    perror("client: select failed.");
	    goto sockfd_exit;
	}

	if(FD_ISSET(sockfd, &rset) && FD_ISSET(sockfd, &wset)){
	    fprintf(stdout, "client: sockfd=%d, with POLLIN_SET POLLOUT_SET\n", sockfd);
	}else if(FD_ISSET(sockfd, &rset) && !FD_ISSET(sockfd, &wset)){
	    fprintf(stdout, "client: sockfd=%d, with POLLIN_SET !POLLOUT_SET\n", sockfd);
	}else if(!FD_ISSET(sockfd, &rset) && FD_ISSET(sockfd, &wset)){
	    fprintf(stdout, "client: sockfd=%d, with !POLLIN_SET POLLOUT_SET\n", sockfd);
	}else{
	    fprintf(stdout, "client: sockfd=%d, with !POLLIN_SET !POLLOUT_SET\n", sockfd);
	}
	
     sockfd_exit:
	close(sockfd);
     }
  exit:
     pthread_exit(NULL);
}

int parse_options(int argc, char *argv[]){
     int ret;
     struct hostent *hptr;
     char buf[BUFSIZE];

     if(argc < 6){
	usage(argv[0]);
	return -1;
     }
     
     while((ret = getopt(argc, argv, "d:s:e:t:h")) != -1){
	switch(ret){
	case 'd':
	    if( (hptr = gethostbyname(optarg)) == NULL){
		fprintf(stderr, "client: gethostbyname error: %s\n", hstrerror(h_errno));
		return -1;
	    }
	    switch(hptr->h_addrtype){
	    case AF_INET:
		server_ip =((struct in_addr*)hptr->h_addr)->s_addr;
		break;
	    default:
		fprintf(stderr, "client: unknow address type\n");
		return -1;
	    }
	    break;
	case 's':
	    port_start = atoi(optarg);
	    break;
	case 'e':
	    port_end = atoi(optarg);
	    break;
	case 't':
	    total_count = atoi(optarg);
	    break;
	case 'h':
	    usage(argv[0]);
	    return -1;
	case '?':
	default:
	    fprintf(stderr, "unknow option %c\n", optopt);
	    return -1;
	}
     }
     return 0;
}

int main(int argc, char *argv[]){
     int i;
     pthread_t tid;
     pthread_attr_t child_thread_attr;
     
     if(parse_options(argc, argv) < 0)
	return 0;

     if( port_end - port_start+1 > POOL_SIZE)
	port_end = port_start + POOL_SIZE -1;
     
     /*initialize port pool*/
     for(i = 0; port_start + i <= port_end; i++){
	port_pool[i] = port_start + i;
     }
     
     /*create threads, one thread per server port*/
     pthread_attr_init(&child_thread_attr);
     pthread_attr_setdetachstate(&child_thread_attr, PTHREAD_CREATE_DETACHED);
     for( i = 0; port_start + i <= port_end ; i++){
	    if( pthread_create(&tid, &child_thread_attr, talk_to_server, (void *)i) != 0 )
		fprintf(stderr, "client: pthread create failed thread %d port %d\n",
			i, port_start+i);
     }
     pthread_exit(NULL);
}
