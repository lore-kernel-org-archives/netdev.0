From: "Patrick R. McManus" <mcmanus@ducksong.com>
Subject: SIOCETHTOOL ioctl() and a corrupted cmd argument
Date: Wed, 5 Mar 2003 16:00:48 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030305210047.GA10824@ducksong.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

this is odd.

My problem is with the cmd argument to a driver's ioctl() handler
getting modified when the caller is non root.

I have a 2.4.19era kernel and am running the e1000 driver, as a
module, from the 2.4.20 kernel. (drivers previous to 4.4.12 tended to
keep resetting themselves on me.) 

my userspace code make a call that looks like this

        struct ethtool_cmd ec;
        int fd;
        int rv = -1;

        memset (&ifr,0,sizeof(ifr));
        strncpy (ifr.ifr_name, getName(),IFNAMSIZ);
        fd = socket (PF_INET,SOCK_DGRAM,0);
        ifr.ifr_data = (char *) &ec;
        ec.cmd = ETHTOOL_GSET;

        fprintf (stderr,"SIOCETHTOOL is %X\n",SIOCETHTOOL);
        if (ioctl(fd, SIOCETHTOOL, &ifr) >=0)

stderr always prints: SIOCETHTOOL is 8946

when I run the userspace code as root the ioctl succeeds, when I run
it as an unpriv'd user it fails.

So I annotated the driver by adding to e1000_ioctl:

     printk(KERN_INFO "general ioctl cmd %X, magic %X\n",cmd,SIOCETHTOOL);

as root I get the expected
Mar  5 15:53:33 mcmanus kernel: general ioctl cmd 8946, magic 8946

as a regular user I get 
Mar  5 15:46:57 mcmanus kernel: general ioctl cmd 89F0, magic 8946

can someone help me with the chain to look at for why the cmd value
might be getting modified?

-Patrick
