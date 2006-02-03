From: Denis Vlasenko <vda@ilport.com.ua>
Subject: Re: [PATCH] acx: make firmware statistics parsing more intelligent
Date: Fri, 3 Feb 2006 14:39:14 +0200
Message-ID: <200602031439.14467.vda@ilport.com.ua>
References: <20060203105857.GB11173@rhlx01.fht-esslingen.de>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Andreas Mohr <andi@rhlx01.fht-esslingen.de>,
	netdev@vger.kernel.org
Return-path: <acx100-devel-admin@lists.sourceforge.net>
To: acx100-devel@lists.sourceforge.net
In-Reply-To: <20060203105857.GB11173@rhlx01.fht-esslingen.de>
Content-Disposition: inline
Sender: acx100-devel-admin@lists.sourceforge.net
Errors-To: acx100-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:acx100-devel@lists.sourceforge.net>
List-Help: <mailto:acx100-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=acx100-devel>
List-Id: netdev.vger.kernel.org

On Friday 03 February 2006 12:58, Andreas Mohr wrote:
> -=A0=A0=A0=A0=A0=A0=A0adev->tx_head =3D (head + 1) % TX_CNT;
> +=A0=A0=A0=A0=A0=A0=A0/* slower: adev->tx_head =3D (head + 1) % TX_CNT; */
> +=A0=A0=A0=A0=A0=A0=A0adev->tx_head =3D head + 1;
> +=A0=A0=A0=A0=A0=A0=A0if (adev->tx_head >=3D TX_CNT)
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0adev->tx_head =3D 0;


struct a {
    int tx_head;
};

#define TX_CNT 16

void f(struct a *adev, int head) {
    adev->tx_head =3D (head + 1) % TX_CNT;
}

void g(struct a *adev, int head) {
    adev->tx_head =3D head + 1;
    if (adev->tx_head >=3D TX_CNT)
        adev->tx_head =3D 0;
}


gcc -Os -S t.c -fomit-frame-pointer -falign-functions=3D1 -falign-labels=3D=
1 -falign-loops=3D1 -falign-jumps=3D1 -mtune=3Di386 -march=3Di386
produces:

f:
        movl    8(%esp), %eax
        incl    %eax
        movl    $16, %edx
        movl    %edx, %ecx
        cltd
        idivl   %ecx
        movl    4(%esp), %eax
        movl    %edx, (%eax)
        ret
        .size   f, .-f
=2Eglobl g
        .type   g, @function
g:
        movl    4(%esp), %edx
        movl    8(%esp), %eax
        incl    %eax
        movl    %eax, (%edx)
        cmpl    $15, %eax
        jle     .L6
        movl    $0, (%edx)
=2EL6:
        ret
        .size   g, .-g
        .ident  "GCC: (GNU) 4.0.0"

Well, gcc obviously failed to realize that "% 16" =3D=3D "& 15".
I'll file a bug. Meanwhile, with & 15 f() is better:

f:
        movl    8(%esp), %eax
        incl    %eax
        andl    $15, %eax
        movl    4(%esp), %edx
        movl    %eax, (%edx)
        ret
        .size   f, .-f
=2Eglobl g
        .type   g, @function
g:
        movl    4(%esp), %edx
        movl    8(%esp), %eax
        incl    %eax
        movl    %eax, (%edx)
        cmpl    $15, %eax
        jle     .L6
        movl    $0, (%edx)
=2EL6:
        ret
        .size   g, .-g
        .ident  "GCC: (GNU) 4.0.0"

=2D-
vda


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
