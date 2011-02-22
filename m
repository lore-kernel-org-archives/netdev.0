From: Jon Zhou <Jon.Zhou@jdsu.com>
Subject: why all packets have same queue no when rps enabled?
Date: Mon, 21 Feb 2011 20:07:49 -0800
Message-ID: <4A6A2125329CFD4D8CC40C9E8ABCAB9F24D3DE6D0C@MILEXCH2.ds.jdsu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og119.obsmtp.com ([64.18.2.16]:36511 "HELO
	exprod7og119.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750859Ab1BVEHw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Feb 2011 23:07:52 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

I expect each incoming packet will have a different queue no. when I enabled RPS on kernel 2.6.36.4

cat /sys/class/net/eth4/queues/rx-0/rps_cpus
00000000,000000ff

CPU0       CPU1       CPU2       CPU3       CPU4       CPU5       CPU6       CPU7       CPU8       CPU9       CPU10      CPU11      CPU12      CPU13      CPU14      CPU15      CPU16
      CPU17      CPU18      CPU19      CPU20      CPU21      CPU22      CPU23      CPU24      CPU25      CPU26      CPU27      CPU28      CPU29      CPU30      CPU31
     HI:          0          0          0          0          0          0          0          0          0          0          0          0          0          0          0          0          0
         0          0          0          0          0          0          0          0          0          0          0          0          0          0          0
   TIMER:    6027512     710165    2623243     542768     427807     217424     192940     217043          0          0          0          0          0          0          0          0          0
         0          0          0          0          0          0          0          0          0          0          0          0          0          0          0
  NET_TX:    1365741         59     750957          0        171          0          3          0          0          0          0          0          0          0          0          0          0
         0          0          0          0          0          0          0          0          0          0          0          0          0          0          0
  NET_RX:   40465750   11140803    8545859   14417762    8913471   12298691   14216845    3348431   < ---- indeed spread across cpus


I manually disable RSS on the intel X520 multiqueue supported NIC.
Cat /proc/interrupts

  87:   21348294          0          0          0          0          0          0          0   PCI-MSI-edge      eth4-rx-0
  88:      38394          0          0          0          0          0          0          0   PCI-MSI-edge      eth4-tx-0



When I tried the below program to filter packet by queue no.I got these results:

struct sock_filter BPF_code[]= {     
    { 0x28,0,0,SKF_AD_OFF+SKF_AD_QUEUE},
    { 0x15, 0, 1, 0x00000001 },
    { 0x6, 0, 0, 0x0000ffff },
    { 0x6, 0, 0, 0x00000000 }
  };

  struct sock_fprog Filter; 
    
  Filter.len = 4;//15;
  Filter.filter = BPF_code;
  
  if ( (sock=socket(PF_PACKET, SOCK_RAW, htons(ETH_P_IP)))<0) {
    perror("socket");
    exit(1);
  }

  /* Set the network card in promiscuos mode */
  strncpy(ethreq.ifr_name,"eth4",IFNAMSIZ);
  if (ioctl(sock,SIOCGIFFLAGS,&ethreq)==-1) {
    perror("ioctl");
    close(sock);
    exit(1);
  }
  ethreq.ifr_flags|=IFF_PROMISC;
  if (ioctl(sock,SIOCSIFFLAGS,&ethreq)==-1) {
    perror("ioctl");
    close(sock);
    exit(1);
  }

  /* Attach the filter to the socket */
  if(setsockopt(sock, SOL_SOCKET, SO_ATTACH_FILTER,&Filter, sizeof(Filter))<0){
    perror("setsockopt");
    close(sock);
    exit(1);
  }
  static int count = 0;
  while (1) {
    printf("#%d----------\n",count++);
    n = recvfrom(sock,buffer,2048,0,NULL,NULL);
    printf("%d bytes read\n",n);
...
}


Looks almost all packets fall at same queue?
Will RPS allocate queue no for each packet? and what hash algorithm rps used? (is it Toeplitz hash algorithm?)

jon
