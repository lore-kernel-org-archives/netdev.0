From: "Ananda Raju" <ananda.raju@neterion.com>
Subject: clarification required on UDP sendfile()
Date: Fri, 9 Sep 2005 18:37:16 -0700
Message-ID: <200509100138.j8A1c8lb003006@guinness.s2io.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'Leonid Grossman'" <Leonid.Grossman@neterion.com>,
        <ravinandan.arakali@neterion.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi, 

We are implementing UDP Large send offload (USO) feature for our Xframe-II
10g Ethernet adapter. We are facing problem in using sendfile().

we have written a client server program which uses sendfile() over udp. We
are facing a problem in which the last sendfile() operation fails to reach
server. This behavior is irrespective of USO feature. 

Client.c has following code. Size of file iperf-2.0.1.tar.gz used for
transfer is 222957
--------------------------------------------------
Main()
{
portno=16000;
fd1 = open("iperf-2.0.1.tar.gz",O_RDWR);
fd = socket(AF_INET,SOCK_DGRAM,0);
bzero((char *) &serv_addr, sizeof(serv_addr));
serv_addr.sin_family = AF_INET;
serv_addr.sin_port = htons(portno);
serv_addr.sin_addr.s_addr = inet_addr("172.10.1.227");
ret = connect(fd,&serv_addr,sizeof(serv_addr));
len = sizeof(client_addr);
off=0;
while (1) {
        size = 40*1024;
        ret = sendfile(fd,fd1,NULL,size);
        printf("size %d \n",ret);
        sleep(1);
        if (ret<=0)
	        exit(0);
}
close(fd);
close(fd1);
}
--------------------------------------------

Server.c has following code 
--------------------------------------------
int portno=16000;
char buf[65000];
main()
{
fd = socket(AF_INET,SOCK_DGRAM,0);
bzero((char *) &serv_addr, sizeof(serv_addr));
serv_addr.sin_family = AF_INET;
serv_addr.sin_port = htons(portno);
ret = bind(fd,(struct sockaddr*)&serv_addr,sizeof(serv_addr));
len = sizeof(client_addr);
while (1){
        ret = recvfrom(fd,&buf,sizeof(buf),0,(struct
sockaddr*)&client_addr,&len);
        printf("size %d \n",ret);
}
}
-------------------------------------------

# ls -l |grep iperf-2.0.1.tar.gz
-rw-r--r--   1 root    root  222957 Sep  8 08:31 iperf-2.0.1.tar.gz
#

#./client
size 40960
size 40960
size 40960
size 40960
size 40960
size 18157  <<< Didn't reach server
size 0
#

#./server
size 40960
size 40960
size 40960
size 40960
size 40960


The last transmit of 18157 bytes didn't reach the server, any reason why
this happens. Also some time the middle frames also won't reach the server.
We did tcpdump and observed that the packets are not put on the wire. The
packets are getting lost in the host network stack. Is this behavior is
expected or We are doing wrong somewhere? 

Regards,
Ananda 
